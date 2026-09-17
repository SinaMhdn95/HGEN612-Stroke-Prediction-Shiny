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

#Import data
dataRaw <- read_csv("healthcare.csv")
view(dataRaw)
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

#PENALIZED LOGISTIC REGRESSION
#Create a logistic regression model using LASSO

lr_mod <- 
  logistic_reg(mixture = 1, penalty = tune()) %>% 
  set_engine("glmnet")

#Create a Recipe for Preprocessing
lr_recipe <- 
  recipe(stroke ~ ., data = dataClean_other) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>% 
  step_zv(all_predictors()) %>% 
  step_normalize(all_predictors()) %>% 
  step_downsample(stroke, under_ratio = 1)

#Create a Workflow
lr_workflow <- 
  workflow() %>% 
  add_model(lr_mod) %>% 
  add_recipe(lr_recipe)

#Create a Grid of Penalty Values
lr_reg_grid <- tibble(penalty = 10^seq(-4, -1, length.out = 30))

#Train & Tune the Model Using the Validation Set
lr_res <- 
  lr_workflow %>% 
  tune_grid(resamples = val_set,
            grid      = lr_reg_grid,
            control   = control_grid(save_pred = TRUE),
            metrics   = metric_set(roc_auc))

#Visualize Results and Select Best Model
lr_plot <- 
  lr_res %>% 
  collect_metrics() %>% 
  ggplot(aes(x = penalty, y = mean)) + 
  geom_point() + 
  geom_line() + 
  ylab("Area under the ROC Curve") +
  scale_x_log10()

lr_plot

show_notes(.Last.tune.result)

lr_best <- 
  lr_res %>% 
  collect_metrics() %>% 
  arrange(desc(mean)) %>% 
  slice(1)

#Finalize Workflow with Best Penalty
lr_workflow_best <- finalize_workflow(
  lr_workflow,
  lr_best
)

#Fit Best Model on Full Training Set
lr_fit <- 
  lr_workflow_best %>% 
  fit(dataClean_other)

lr_fit %>%
  extract_fit_parsnip() %>% 
  tidy()

#Evaluate on Final Test Set
lr_last_fit <- last_fit(
  lr_workflow_best,
  splits
)

lr_last_fit %>%
  collect_metrics()

lr_last_fit %>%
  collect_predictions() %>% 
  conf_mat(truth = stroke, estimate = .pred_class) %>% 
  autoplot(type = "heatmap") +
  scale_fill_gradient(low = "lightblue", high = "darkred") +
  theme_minimal()

#calculating th. sensitivity and specificity, Accuracy, AUC and misclassification
preds <- lr_last_fit %>% collect_predictions()

metric_set(
  sens, spec, ppv, npv, accuracy, roc_auc
)(preds, truth = stroke, estimate = .pred_class, .pred_Yes)



