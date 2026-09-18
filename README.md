# Stroke Prediction — HGEN 612 Final Project

[![R checks](https://github.com/SinaMhdn95/HGEN612-Stroke-Prediction-Shiny/actions/workflows/r-check.yml/badge.svg)](https://github.com/SinaMhdn95/HGEN612-Stroke-Prediction-Shiny/actions/workflows/r-check.yml)

This repository mirrors the original HGEN 612 final-project structure by Sina
Mahdiani. It is an interactive Shiny flexdashboard for educational stroke-risk
classification using logistic regression, random forest, and XGBoost.

**[Open the deployed Shiny app](https://sinamhdn.shinyapps.io/Stroke_Prediction/)**

> **Educational use only:** this application is not a validated clinical
> prediction tool, does not diagnose stroke, and must not be used for medical
> decisions.

## Run the original project locally

1. Select **Code → Download ZIP** on GitHub and extract it.
2. Open `Final_Sina.Rproj` in RStudio.
3. Open `Final3_Sina.Rmd`.
4. Click **Run Document** (or select **Run → Run All**).

The dashboard expects the files in this same folder: `healthcare.csv`,
`lr_model.rds`, `rf_model.rds`, `xgb_model.rds`, `stroke7.png`, and
`stroke.mp4`. Do not run the R Markdown file from a different working folder.

## Repository layout

```text
.
├── Final_Sina.Rproj       # Open this first in RStudio
├── Final3_Sina.Rmd        # Original Shiny flexdashboard
├── healthcare.csv         # Educational source data
├── lr_model.rds           # Original fitted logistic model
├── rf_model.rds           # Original fitted random-forest model
├── xgb_model.rds          # Original fitted XGBoost model
├── low_volume_MLs.R       # Original supporting model code
├── RanFor_Final.R         # Original random-forest code
├── XGboost_Final.R        # Original XGBoost code
├── stroke7.png            # Dashboard logo/favicon
└── stroke.mp4             # Dashboard media asset
```

## Data and reuse

The source page for the dataset identifies a confidential upstream source,
limits use to education, requests author credit, and lists the files as
copyrighted by their original authors. See [NOTICE.md](NOTICE.md) before
reusing or redistributing the data.

## Author

Sina Mahdiani — HGEN 612, Spring 2025
