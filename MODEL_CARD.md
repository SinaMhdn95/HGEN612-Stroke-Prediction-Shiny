# Model card

## Intended use

These models were built for an HGEN 612 classroom demonstration of binary classification. They are intended only for learning, code review, and reproduction of the course project. They are not intended for medical screening, diagnosis, treatment, triage, or individual risk communication.

## Data and split

- Source: Kaggle's Stroke Prediction Dataset (`fedesoriano`)
- Complete records after the documented exclusions: 3,426
- Outcome-positive records after exclusions: 180
- Stratified split: 2,740 training rows and 686 test rows
- Random seed: 123

Records with missing values or an unknown smoking status are excluded, matching the final course workflow. The identifier field is assigned a non-predictor role.

## Held-out results

| Model | Accuracy | Sensitivity | Specificity | ROC AUC |
|---|---:|---:|---:|---:|
| Penalized logistic regression | 0.708 | 0.800 | 0.704 | 0.859 |
| Random forest | 0.882 | 0.143 | 0.922 | 0.764 |
| XGBoost | 0.662 | 0.857 | 0.651 | 0.824 |

The class imbalance makes accuracy alone misleading. For example, the random forest has the highest accuracy but very low sensitivity on the held-out split.

## Important limitations

- The dataset's upstream source and sampling design are not documented sufficiently for clinical interpretation.
- The dataset is small and highly imbalanced.
- Metrics come from one fixed held-out split and do not establish external validity.
- No calibration analysis, subgroup fairness assessment, prospective validation, or clinical utility analysis was performed.
- Dashboard probabilities are model outputs for a classroom exercise, not estimates of an individual's real-world risk.

