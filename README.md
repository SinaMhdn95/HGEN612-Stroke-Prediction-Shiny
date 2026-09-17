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
├── scripts/                 # Dependency and training utilities
└── tests/smoke_test.R       # Data, model, and prediction checks
```

## Run locally

Use R 4.3 or newer. From the repository root:

```r
source("scripts/install_packages.R")
rmarkdown::run("app.Rmd")
```

To rebuild the model artifacts:

```sh
Rscript scripts/train_models.R
```

The split and model-building process use a fixed random seed (`123`) for reproducibility.

## Data source and limitations

The project uses the [Stroke Prediction Dataset](https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset) published by Kaggle user `fedesoriano`. The source page identifies a confidential upstream source, limits use to education, asks users to credit the author, and labels the data files as copyrighted by their original authors. For that reason this repository is private and no broader data license is claimed.

The data are highly imbalanced and the source does not document a representative sampling design. Model scores therefore describe this classroom dataset and should not be interpreted as clinical performance or population risk.

## Author

Sina Mahdiani — HGEN 612, Spring 2025
