# Stroke Prediction Shiny Dashboard

[![R checks](https://github.com/SinaMhdn95/HGEN612-Stroke-Prediction-Shiny/actions/workflows/r-check.yml/badge.svg)](https://github.com/SinaMhdn95/HGEN612-Stroke-Prediction-Shiny/actions/workflows/r-check.yml)

A Shiny-enabled `flexdashboard` created for the **HGEN 612: Methods in Data Science** final project at Virginia Commonwealth University. It demonstrates an end-to-end classification workflow with logistic regression, random forest, and XGBoost.

> **Educational use only:** this project is not a medical device, has not been clinically validated, and must not be used for diagnosis, treatment, or individual risk assessment.

## Features

- Interactive exploration of demographic and health-related variables
- Stratified held-out model evaluation
- ROC curves, confusion matrices, accuracy, sensitivity, specificity, and AUC
- Variable-importance views for three model families
- A clearly labeled classroom prediction demonstration
- Reproducible model-building script and automated smoke tests

## Repository layout

```text
.
├── app.Rmd                  # Shiny flexdashboard application
├── R/modeling.R             # Data validation and model definitions
├── data/                    # Educational source dataset
├── models/model_bundle.rds  # Reproducible fitted/evaluation artifacts
├── run_app.R                # One-file local launcher
├── scripts/                 # Dependency and training utilities
└── tests/smoke_test.R       # Data, model, and prediction checks
```

## Run locally

`app.Rmd` is not a standalone download: it needs the accompanying `R/`,
`data/`, and `models/` directories. GitHub hosts the source code but cannot run
a Shiny application directly.

1. On GitHub, select **Code → Download ZIP** (or clone the repository).
2. Extract the ZIP.
3. Open `HGEN612-Stroke-Prediction-Shiny.Rproj` in RStudio.
4. Open `run_app.R` and select **Source**, or run:

```r
source("run_app.R")
```

The first run installs any missing R packages and then opens the application in
a local browser window. Use R 4.3 or newer.

For a permanently hosted web app, deploy this repository to a Shiny-compatible
service such as shinyapps.io or Posit Connect. GitHub Pages only serves static
files and cannot execute this Shiny application.

To rebuild the model artifacts:

```sh
Rscript scripts/train_models.R
```

The split and model-building process use a fixed random seed (`123`) for reproducibility.

## Data source and limitations

The project uses the [Stroke Prediction Dataset](https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset) published by Kaggle user `fedesoriano`. The source page identifies a confidential upstream source, limits use to education, asks users to credit the author, and labels the data files as copyrighted by their original authors. It is included here for educational reproducibility; its public availability in this repository does not grant broader reuse or redistribution rights.

The data are highly imbalanced and the source does not document a representative sampling design. Model scores therefore describe this classroom dataset and should not be interpreted as clinical performance or population risk.

## Author

Sina Mahdiani — HGEN 612, Spring 2025
