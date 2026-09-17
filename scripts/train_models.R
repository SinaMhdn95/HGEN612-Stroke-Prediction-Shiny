required <- c(
  "readr", "dplyr", "tidyr", "janitor", "tidymodels", "themis",
  "glmnet", "ranger", "xgboost"
)

missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Install missing packages first: ", paste(missing, collapse = ", "))
}

source("R/modeling.R")
data <- load_stroke_data("data/healthcare-dataset-stroke-data.csv")
bundle <- train_model_bundle(data, seed = 123L)
dir.create("models", showWarnings = FALSE)
saveRDS(bundle, "models/model_bundle.rds", version = 3)

message(
  "Saved model bundle for ", bundle$metadata$total_rows,
  " complete educational records."
)

