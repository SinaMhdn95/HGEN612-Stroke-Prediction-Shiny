required <- c(
  "bslib", "dplyr", "DT", "flexdashboard", "glmnet", "janitor",
  "plotly", "ranger", "readr", "rmarkdown", "rsample", "shiny",
  "themis", "tidymodels", "tidyr", "vip", "xgboost"
)

missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}

message("All application dependencies are installed.")

