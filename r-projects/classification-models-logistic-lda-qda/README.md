# Classification Models: Logistic Regression, LDA, and QDA

## Overview
This project explores binary classification techniques across two applied case studies: predicting leukemia patient survival and forecasting stock market direction. Logistic regression, Linear Discriminant Analysis (LDA), and Quadratic Discriminant Analysis (QDA) are implemented and compared using model diagnostics and predictive performance metrics.

---

## Case Study 1: Leukemia Survival Analysis

### Objective
To assess whether white blood cell count (WBC) and antigen presence are associated with survival of at least 24 weeks among leukemia patients.

### Data
- Source: `leuk` dataset (MASS package)
- Observations: 33 patients
- Response variable:
  - Binary survival outcome (≥ 24 weeks vs. < 24 weeks)
- Predictors:
  - Log-transformed white blood cell count
  - Antigen presence (binary factor)

### Methods
- Logistic regression with log-transformed predictors
- Odds ratio interpretation
- Model fit assessment using residual deviance
- Visualization of predicted survival probabilities

### Key Findings
- Antigen presence is a statistically significant predictor of survival
- White blood cell count is not statistically significant after transformation
- Patients with antigen presence have substantially higher odds of surviving at least 24 weeks

---

## Case Study 2: Stock Market Direction Classification

### Objective
To predict weekly stock market direction (Up vs. Down) using historical lagged returns and trading volume.

### Data
- Source: `Weekly` dataset (ISLR package)
- Observations: 1,089 weeks
- Response variable:
  - Market direction (Up/Down)
- Predictors:
  - Lagged returns (Lag1–Lag5)
  - Trading volume

### Methods
- Logistic regression (full and reduced models)
- Linear Discriminant Analysis (LDA)
- Quadratic Discriminant Analysis (QDA)
- Train/test split for out-of-sample evaluation
- Confusion matrices and misclassification rates

### Key Findings
- Only Lag2 shows statistical significance across models
- All models perform similarly, with ~56% accuracy
- None of the classification methods meaningfully outperform random guessing
- Logistic regression performs marginally better than LDA and QDA

---

## Skills Demonstrated
- Binary classification modeling
- Logistic regression and odds interpretation
- LDA and QDA implementation
- Model comparison and evaluation
- Confusion matrix analysis
- Train/test validation
- Critical assessment of predictive limitations

---

## Files
- `HW3_Data_Analysis.pdf` – Full analytical report
- `DA_HW3.R` – Reproducible R code
- `HW3_DA_LaTeX.tex` – LaTeX source for report

