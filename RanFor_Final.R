#Load the libraries
library(readr)       # for importing data
library(vip)         # for variable importance plots
library(janitor)     # for tabyl
library(forcats)     # for factor operations
library(tidymodels)
library(tidyverse)
library(modelr)
library(tidyverse)
library(readxl)
library(broom)
library(ggfortify)
library(performance)
library(ggplot2)
library(plotly)
library(dplyr)
library(skimr)
library(rsample)
library(themis)
library(yardstick)
library(ranger)

#Import data
dataRaw <- read_csv("healthcare.csv")
str(dataRaw)
summary(dataRaw)
colSums(is.na(dataRaw))

#Clean data
dataClean <- dataRaw %>%
  clean_names() %>%
  mutate(
    ever_married    = if_else(ever_married    == "Yes", 1L, 0L),
    residence_type  = if_else(residence_type  == "Urban", 1L, 0L), #Urban =1, Rural =0
    gender          = if_else(gender  == "Male", 1L, 0L), #Male=1, Female=0
    stroke = factor(stroke, levels = c(0, 1), labels = c("No", "Yes")),
    work_type       = as.factor(work_type),
    smoking_status  = as.factor(smoking_status),
    bmi             = as.numeric(na_if(bmi, "N/A"))
  )



skim(dataClean)
glimpse(dataClean)
view(dataClean)


dataClean2 <- dataClean %>% 
  drop_na() %>% 
  filter(smoking_status != "Unknown")

#DATA SPLITTING AND RESAMPLING

set.seed(123)
splits <- initial_split(dataClean2, strata = stroke)

dataClean_other <- training(splits)
dataClean_test  <- testing(splits)

# training set proportions by stroke
tabyl(dataClean_other$stroke)

# test set proportions by stroke
tabyl(dataClean_test$stroke)

# training and test sets have similar proportions which is good!
#create a validation set

set.seed(234)
val_set <- validation_split(dataClean_other,
                            strata = stroke,
                            prop = 0.8)

val_set
class(val_set)

# Data splitting
set.seed(123)
splits <- initial_split(dataClean2, strata = stroke)
dataClean_other <- training(splits)
dataClean_test  <- testing(splits)

# Validation split
set.seed(234)
val_set <- validation_split(dataClean_other, strata = stroke, prop = 0.8)

# Recipe with downsampling
rf_recipe <- 
  recipe(stroke ~ ., data = dataClean_other) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>%
  step_zv(all_predictors()) %>%
  step_normalize(all_predictors()) %>%
  step_downsample(stroke, under_ratio = 1)

# Random Forest model
rf_mod <- 
  rand_forest(mtry = tune(), trees = 1000, min_n = tune()) %>%
  set_engine("ranger") %>%
  set_mode("classification")

# Workflow
rf_workflow <- 
  workflow() %>%
  add_model(rf_mod) %>%
  add_recipe(rf_recipe)

# Tuning
rf_res <- rf_workflow %>%
  tune_grid(
    resamples = val_set,
    grid = 10,
    metrics = metric_set(roc_auc, accuracy, sens, specificity),
    control = control_grid(save_pred = TRUE)
  )

# Best model
rf_best <- select_best(rf_res, metric = "roc_auc")
rf_workflow_best <- finalize_workflow(rf_workflow, rf_best)

# Fit on training, evaluate on test
rf_last_fit <- last_fit(rf_workflow_best, splits)

# Metrics
rf_last_fit %>% collect_metrics()

# Confusion matrix heatmap
rf_last_fit %>%
  collect_predictions() %>%
  conf_mat(truth = stroke, estimate = .pred_class) %>%
  autoplot(type = "heatmap") +
  scale_fill_gradient(low = "lightgreen", high = "darkgreen") +
  theme_minimal()

# Metrics: Sensitivity, Specificity, PPV, NPV, Accuracy, AUC
preds <- rf_last_fit %>% collect_predictions()

metric_set(sens, specificity, ppv, npv, accuracy, roc_auc)(
  preds, truth = stroke, estimate = .pred_class, .pred_Yes
)

