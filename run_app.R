# Download the complete repository before running this file. The app depends on
# the accompanying R/, data/, and models/ directories.

`%||%` <- function(x, y) if (is.null(x)) y else x
script_args <- commandArgs(trailingOnly = FALSE)
script_file_arg <- grep("^--file=", script_args, value = TRUE)
script_path <- if (length(script_file_arg)) {
  sub("^--file=", "", script_file_arg[[1]])
} else {
  tryCatch(sys.frame(1)$ofile, error = function(...) NULL) %||% "run_app.R"
}

project_dir <- dirname(normalizePath(script_path, mustWork = TRUE))
original_dir <- setwd(project_dir)
on.exit(setwd(original_dir), add = TRUE)

required_files <- c(
  "app.Rmd",
  "R/modeling.R",
  "data/healthcare-dataset-stroke-data.csv",
  "models/model_bundle.rds"
)

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files)) {
  stop(
    "The complete repository is required. In GitHub, choose Code > Download ZIP, ",
    "extract it, open HGEN612-Stroke-Prediction-Shiny.Rproj, and run run_app.R. ",
    "Missing: ", paste(missing_files, collapse = ", "),
    call. = FALSE
  )
}

source("scripts/install_packages.R")
rmarkdown::run("app.Rmd")
