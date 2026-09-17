load_stroke_data <- function(path) {
  required <- c(
    "id", "gender", "age", "hypertension", "heart_disease",
    "ever_married", "work_type", "residence_type",
    "avg_glucose_level", "bmi", "smoking_status", "stroke"
  )

  data <- readr::read_csv(path, show_col_types = FALSE) |>
    janitor::clean_names()

  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop("Missing required columns: ", paste(missing, collapse = ", "))
  }

  data |>
    dplyr::mutate(
      gender = factor(gender),
      ever_married = factor(ever_married),
      work_type = factor(work_type),
      residence_type = factor(residence_type),
      smoking_status = factor(smoking_status),
      bmi = suppressWarnings(as.numeric(bmi)),
      stroke = factor(stroke, levels = c(0, 1), labels = c("No", "Yes"))
    ) |>
    dplyr::filter(smoking_status != "Unknown") |>
    tidyr::drop_na() |>
    droplevels()
}

make_stroke_workflows <- function(training_data) {
  base_recipe <- recipes::recipe(stroke ~ ., data = training_data) |>
    recipes::update_role(id, new_role = "ID") |>
    recipes::step_dummy(recipes::all_nominal_predictors()) |>
    recipes::step_zv(recipes::all_predictors()) |>
    recipes::step_normalize(recipes::all_numeric_predictors())

  logistic_recipe <- base_recipe |>
    themis::step_downsample(stroke, under_ratio = 1, skip = TRUE)

  tree_recipe <- base_recipe |>
    themis::step_smote(stroke, over_ratio = 1, neighbors = 5, skip = TRUE)

  logistic_model <- parsnip::logistic_reg(penalty = 0.0215443469, mixture = 1) |>
    parsnip::set_engine("glmnet") |>
    parsnip::set_mode("classification")

  random_forest_model <- parsnip::rand_forest(mtry = 7, trees = 1000, min_n = 35) |>
    parsnip::set_engine("ranger", importance = "impurity") |>
    parsnip::set_mode("classification")

  xgboost_model <- parsnip::boost_tree(
    mtry = 11,
    trees = 1000,
    tree_depth = 8,
    learn_rate = 0.0464158883,
    loss_reduction = 31.6227766,
    sample_size = 0.2
  ) |>
    parsnip::set_engine("xgboost") |>
    parsnip::set_mode("classification")

  list(
    logistic = workflows::workflow() |>
      workflows::add_recipe(logistic_recipe) |>
      workflows::add_model(logistic_model),
    random_forest = workflows::workflow() |>
      workflows::add_recipe(tree_recipe) |>
      workflows::add_model(random_forest_model),
    xgboost = workflows::workflow() |>
      workflows::add_recipe(tree_recipe) |>
      workflows::add_model(xgboost_model)
  )
}

train_model_bundle <- function(data, seed = 123L) {
  set.seed(seed)
  split <- rsample::initial_split(data, prop = 0.8, strata = stroke)
  training_data <- rsample::training(split)
  workflows <- make_stroke_workflows(training_data)

  evaluations <- lapply(workflows, tune::last_fit, split = split)
  production <- lapply(workflows, parsnip::fit, data = data)

  list(
    evaluations = evaluations,
    production = production,
    metadata = list(
      seed = seed,
      training_rows = nrow(training_data),
      testing_rows = nrow(rsample::testing(split)),
      total_rows = nrow(data),
      created_with = R.version.string
    )
  )
}

