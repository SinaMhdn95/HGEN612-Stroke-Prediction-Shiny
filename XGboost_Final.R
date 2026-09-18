# Load required libraries
library(tidymodels)
library(themis)        # for step_smote()
library(readr)
library(janitor)
library(dplyr)
library(skimr)
library(vip)
library(xgboost)       # for the xgboost engine


# Import and clean data
getwd()
dataRaw <- read_csv("healthcare.csv")

dataClean <- dataRaw %>%
  clean_names() %>%
  mutate(
    ever_married    = if_else(ever_married == "Yes", 1L, 0L),
    residence_type  = if_else(residence_type == "Urban", 1L, 0L),
    gender          = if_else(gender == "Male", 1L, 0L),
    stroke          = factor(stroke, levels = c(0, 1), labels = c("No", "Yes")),
    work_type       = as.factor(work_type),
    smoking_status  = as.factor(smoking_status),
    bmi             = as.numeric(na_if(bmi, "N/A"))
  )

dataClean2 <- dataClean %>%
  drop_na() %>%
  filter(smoking_status != "Unknown")

View(dataClean2)
str(dataClean2)
summary(dataClean2)
# Split data
set.seed(123)
splits <- initial_split(dataClean2, strata = stroke)
dataClean_other <- training(splits)
dataClean_test  <- testing(splits)

# Validation set from training
set.seed(234)
val_set <- validation_split(dataClean_other, strata = stroke, prop = 0.8)

# Recipe with SMOTE for imbalance
xgb_recipe <- recipe(stroke ~ ., data = dataClean_other) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>%
  step_zv(all_predictors()) %>%
  step_normalize(all_predictors()) %>%
  step_smote(stroke)

# XGBoost model specification
xgb_mod <- 
  boost_tree(trees = 1000, 
             tree_depth = tune(), 
             learn_rate = tune(), 
             loss_reduction = tune(),
             sample_size = tune(), 
             mtry = tune()) %>% 
  set_engine("xgboost") %>% 
  set_mode("classification")

# Workflow
xgb_workflow <- workflow() %>%
  add_model(xgb_mod) %>%
  add_recipe(xgb_recipe)

# Tune the model
xgb_res <- tune_grid(
  xgb_workflow,
  resamples = val_set,
  grid = 10,
  metrics = metric_set(roc_auc, accuracy, sens, specificity),
  control = control_grid(save_pred = TRUE)
)

# Best model by ROC AUC
xgb_best <- select_best(xgb_res, metric = "roc_auc")
xgb_workflow_best <- finalize_workflow(xgb_workflow, xgb_best)

# Final fit and evaluation on test set
xgb_last_fit <- last_fit(xgb_workflow_best, splits)

# Collect metrics
xgb_last_fit %>% collect_metrics()

# Confusion matrix heatmap
xgb_last_fit %>%
  collect_predictions() %>%
  conf_mat(truth = stroke, estimate = .pred_class) %>%
  autoplot(type = "heatmap") +
  scale_fill_gradient(low = "lightblue", high = "darkred") +
  theme_minimal()

# All final evaluation metrics
xgb_preds <- xgb_last_fit %>% collect_predictions()

metric_set(sens, specificity, ppv, npv, accuracy, roc_auc)(
  xgb_preds, truth = stroke, estimate = .pred_class, .pred_Yes
) %>%
  print()
