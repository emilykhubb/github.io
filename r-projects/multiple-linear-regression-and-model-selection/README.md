# Multiple Linear Regression and Model Selection

## Overview
This project applies multiple linear regression techniques to analyze factors influencing pizza delivery time using a simulated restaurant delivery dataset. The analysis focuses on identifying significant predictors, selecting an optimal model using information criteria, and evaluating model assumptions to assess reliability and interpretability.

---

## Data
- Source: Simulated pizza delivery dataset
- Observations: 1,266 delivery orders
- Response variable:
  - Delivery time (minutes)
- Key predictors:
  - Temperature at arrival
  - Branch location
  - Day of week
  - Driver
  - Operator
  - Total bill amount
  - Number of pizzas ordered
  - Discount customer status

---

## Methods
- Multiple linear regression with both numeric and categorical predictors
- Coefficient interpretation and confidence interval estimation
- Backward model selection using AIC (`stepAIC`)
- Model comparison using adjusted R²
- Regression diagnostics:
  - Residuals vs. fitted plots
  - Q–Q plots and Lilliefors normality test
  - Constant variance assessment
  - Autocorrelation (ACF) analysis
- Covariate independence checks:
  - Spearman correlation for numeric variables
  - Chi-square tests and Cramer’s V for categorical variables
- Quadratic term testing to assess nonlinearity
- Prediction and percent error evaluation for a new observation

---

## Key Findings
- Temperature, branch location, driver, bill amount, and number of pizzas are significant predictors of delivery time
- Backward selection using AIC identifies a reduced model with similar predictive performance to the full model
- Regression assumptions are partially violated, particularly normality and constant variance
- Including a quadratic temperature term improves model fit, indicating a nonlinear relationship
- The final model predicts delivery time with approximately 4% percent error for a held-out observation

---

## Skills Demonstrated
- Multiple linear regression modeling
- Model selection using information criteria
- Interpretation of categorical and continuous predictors
- Regression diagnostics and assumption checking
- Polynomial feature testing
- Predictive evaluation and error assessment

---

## Files
- `HW2_Data_Analysis.pdf` – Full analytical report
- `DA_HW2.R` – Reproducible R code for analysis
- `HW2_DA_LaTeX.tex` – LaTeX source for report generation

