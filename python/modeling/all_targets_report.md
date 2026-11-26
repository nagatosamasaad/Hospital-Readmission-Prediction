# Carelytics — all modeling targets

## 1. Observed 30-day return
See model_card.md for the full return model, validation design, subgroup analyses, uncertainty and limitations.

## 2. Daily claim amount
Target is the sum of the total_claim source field on the index patient-day, requiring all same-day amounts to be observed and nonnegative. Component fields are not assumed to sum to total_claim. Currency and semantics are unverified, so outputs are in source units. Features are available at the start of the index day; current claim fields and diagnoses are excluded. Three expanding temporal folds compare median baseline, log-target Ridge, random forest and histogram boosting. All candidates are trained only on the training period; separate selection data choose minimum MAE. Selected model: **median_baseline**. The frozen test is used for reporting only.

| model           |     n |     MAE |    RMSE |        R2 |   mean_observed |   mean_predicted |   zero_target_fraction |
|:----------------|------:|--------:|--------:|----------:|----------------:|-----------------:|-----------------------:|
| median_baseline | 21215 | 10.5178 | 19.0071 | -0.426027 |         24.6389 |            14.25 |                      0 |
| median_baseline | 21215 | 10.5178 | 19.0071 | -0.426027 |         24.6389 |            14.25 |                      0 |

A separate 2023 calibration period estimates absolute-residual intervals with nominal 90% coverage. Actual test coverage is **88.7%**, with mean width **35.1000** source units. Repeated patients and temporal drift invalidate an exchangeability guarantee; coverage is measured, not promised. Zero-value concentration and outliers are reported rather than hidden. The selected cost model does NOT beat the median baseline on the locked test; this result is retained, with no test-based reselection. Totals reported as zero while components were positive were rebuilt from the components upstream (flag total_claim_rebuilt); the target distribution by period is printed in the two-stage section. Negative R² is retained when present. No operational billing forecast is claimed.

## 3. Observed ICD chapter grouping
The target is the current-day syntax-derived ICD chapter grouping, not a clinically validated diagnosis. Same-day different chapters are MULTIPLE_CHAPTERS. Unknown, unmapped or malformed code groups are excluded. Current ICD codes, diagnosis text and disease labels never enter the predictors. Targets with fewer than 100 training observations are mapped to OTHER_RARE, using training data only (within each temporal fold for CV). Three expanding temporal folds starting October 2019, April 2020 and August 2020 compare a majority baseline, logistic regression and balanced random forest. Separate selection data choose maximum macro F1, so minority classes influence selection. Selected model: **balanced_forest**.

| model                  |     n |   macro_F1 |   weighted_F1 |   accuracy |   balanced_accuracy |
|:-----------------------|------:|-----------:|--------------:|-----------:|--------------------:|
| balanced_forest        | 19664 |  0.0757714 |      0.154777 |   0.16014  |           0.11624   |
| most_frequent_baseline | 19664 |  0.0206545 |      0.084891 |   0.228336 |           0.0555556 |

Full per-class precision, recall, F1 and support are saved in diagnosis_class_report.csv. Some groups may have zero recall. These failures remain visible. Predicted group labels are research outputs, not diagnoses or recommended treatments. Probability calibration is not claimed for this multiclass model.

## Shared methodology and limitations
See additional_split_summary.csv for exact target-specific sample counts. Costs and diagnosis labels do not require a future return window, so they use their own eligible cohorts. Only reliable identified dates enter these datasets. Same patients may recur over time to represent longitudinal use; patient IDs are never features. Missing current ages are imputed inside training pipelines; original contemporaneous demographics avoid future-derived conflict flags. History is strictly before the index day and left-truncated by source coverage. Models omit current billing/diagnosis fields whose availability is uncertain. No test-period result is used for model selection. Patterns can reflect billing practices, incomplete capture and changing coverage rather than patient biology. External/prospective validation, semantic verification and clinical utility review are required before real use.

The return model includes patient-cluster intervals and descriptive demographic subgroup metrics. Equivalent fairness and uncertainty validation for every additional target has not been established. Claim intervals are descriptive under temporal dependence, and diagnosis metrics do not establish clinical accuracy. Serialized models have been reloaded and prediction equivalence verified. Source files and the original descriptive analysis are preserved.

Method reference: https://scikit-learn.org/stable/common_pitfalls.html
