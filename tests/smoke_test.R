required_files <- c(
  "app.Rmd",
  "R/modeling.R",
  "data/healthcare-dataset-stroke-data.csv",
  "models/model_bundle.rds"
)

stopifnot("Required files are present" = all(file.exists(required_files)))

source("R/modeling.R")
stopifnot("workflows is installed" = requireNamespace("workflows", quietly = TRUE))
data <- load_stroke_data("data/healthcare-dataset-stroke-data.csv")
stopifnot("Clean data has expected dimensions" = identical(dim(data), c(3426L, 12L)))
stopifnot("Outcome levels are stable" = identical(levels(data$stroke), c("No", "Yes")))
stopifnot("All IDs are unique" = !anyDuplicated(data$id))

bundle <- readRDS("models/model_bundle.rds")
expected_models <- c("logistic", "random_forest", "xgboost")
stopifnot("All evaluation fits are present" = setequal(names(bundle$evaluations), expected_models))
stopifnot("All production fits are present" = setequal(names(bundle$production), expected_models))

example <- data[1, setdiff(names(data), "stroke"), drop = FALSE]
for (name in expected_models) {
  probability <- predict(bundle$production[[name]], example, type = "prob")$.pred_Yes
  stopifnot("Prediction is finite and bounded" = is.finite(probability) && probability >= 0 && probability <= 1)
}

source_text <- paste(readLines("app.Rmd", warn = FALSE), collapse = "\n")
stopifnot("App has no absolute home path" = !grepl("/Users/", source_text, fixed = TRUE))
stopifnot("App contains the medical-use disclaimer" = grepl("not a validated", source_text, fixed = TRUE))

message("Stroke prediction app smoke test passed.")
