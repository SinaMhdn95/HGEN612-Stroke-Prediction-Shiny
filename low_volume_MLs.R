# model_training.R
# Train and save tuned models for use in Shiny app

library(tidymodels)
library(themis)
library(xgboost)
library(readr)
library(janitor)
library(dplyr)

# 1. Load and clean data
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
  ) %>%
  drop_na() %>%
  filter(smoking_status != "Unknown")

# Save cleaned training data for predictions
set.seed(123)
splits <- initial_split(dataClean, strata = stroke)
dataClean_other <- training(splits)
saveRDS(dataClean_other, "train_data.rds")

val_set <- validation_split(dataClean_other, strata = stroke, prop = 0.8)

# Helper function to make recipe
make_recipe <- function(data, use_smote = FALSE) {
  rec <- recipe(stroke ~ ., data = data) %>%
    step_dummy(all_nominal(), -all_outcomes()) %>%
    step_zv(all_predictors()) %>%
    step_normalize(all_predictors())
  if (use_smote) rec %>% step_smote(stroke)
  else rec %>% step_downsample(stroke, under_ratio = 1)
}

# Logistic Regression
lr_recipe <- make_recipe(dataClean_other)
lr_mod <- logistic_reg(mixture = 1, penalty = tune()) %>%
  set_engine("glmnet") %>%
  set_mode("classification")
lr_workflow <- workflow() %>% add_model(lr_mod) %>% add_recipe(lr_recipe)
lr_res <- tune_grid(
  lr_workflow,
  resamples = val_set,
  grid = tibble(penalty = 10^seq(-4, -1, length.out = 10)),
  control = control_grid(save_pred = TRUE),
  metrics = metric_set(roc_auc, accuracy, sens, specificity)
)
lr_best <- select_best(lr_res, metric = "roc_auc")
lr_workflow_best <- finalize_workflow(lr_workflow, lr_best)
saveRDS(lr_workflow_best, "lr_model.rds")

# Random Forest
rf_recipe <- make_recipe(dataClean_other)
rf_mod <- rand_forest(mtry = tune(), trees = 1000, min_n = tune()) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("classification")
rf_workflow <- workflow() %>% add_model(rf_mod) %>% add_recipe(rf_recipe)
rf_res <- tune_grid(
  rf_workflow,
  resamples = val_set,
  grid = 10,
  metrics = metric_set(roc_auc, accuracy, sens, specificity),
  control = control_grid(save_pred = TRUE)
)
rf_best <- select_best(rf_res, metric = "roc_auc")
rf_workflow_best <- finalize_workflow(rf_workflow, rf_best)
saveRDS(rf_workflow_best, "rf_model.rds")

# XGBoost
xgb_recipe <- make_recipe(dataClean_other, use_smote = TRUE)
xgb_mod <- boost_tree(
  trees = 1000,
  tree_depth = tune(),
  learn_rate = tune(),
  loss_reduction = tune(),
  sample_size = tune(),
  mtry = tune()
) %>%
  set_engine("xgboost") %>%
  set_mode("classification")
xgb_workflow <- workflow() %>% add_model(xgb_mod) %>% add_recipe(xgb_recipe)
xgb_res <- tune_grid(
  xgb_workflow,
  resamples = val_set,
  grid = 10,
  metrics = metric_set(roc_auc, accuracy, sens, specificity),
  control = control_grid(save_pred = TRUE)
)
xgb_best <- select_best(xgb_res, metric = "roc_auc")
xgb_workflow_best <- finalize_workflow(xgb_workflow, xgb_best)
saveRDS(xgb_workflow_best, "xgb_model.rds")

