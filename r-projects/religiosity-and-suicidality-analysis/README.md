# Religiosity and Lifetime Suicidality in Bipolar I
### A Penalized Logistic Regression Analysis

## Overview
This project investigates whether religiosity is associated with lifetime suicidality among individuals with Bipolar I disorder. Using data from the National Survey of American Life (NSAL), a standardized composite religiosity index was constructed and evaluated as a predictor of lifetime suicidal ideation, planning, or attempts.

Given the small sample size and low event rate in this subgroup, bias-reduced logistic regression (Firth correction) was used to produce stable and interpretable estimates. Results indicate no statistically significant association between religiosity and lifetime suicidality after accounting for key methodological constraints.

---

## Research Question
Is higher religiosity associated with increased or decreased odds of lifetime suicidality among individuals with Bipolar I disorder?

---

## Data
- Source: Collaborative Psychiatric Epidemiology Surveys (CPES), NSAL component
- Study population:
  - NSAL respondents with lifetime Bipolar I disorder
- Final analytic sample:
  - N = 40 respondents
  - 22 lifetime suicidality events

### Outcome
- **Lifetime suicidality (binary)**  
  Defined as endorsement of any of the following:
  - Suicidal ideation
  - Suicide planning
  - Suicide attempt (during depressive episode or lifetime)

### Primary Predictor
- **Composite religiosity index**
  - Constructed from four survey items:
    - Importance of religion
    - Prayer frequency
    - Self-rated religiosity
    - Church attendance since age 18
  - Items were scored, averaged (≥3 required), and standardized (z-score)

### Covariates
- Age (standardized)
- Sex (male vs female)

---

## Methods
- Data filtering and cohort construction using CPES/NSAL survey structure
- Descriptive analysis of suicidality components and religiosity distribution
- Exploratory visualization by religiosity tertiles
- Logistic regression modeling:
  - Firth penalized logistic regression (primary)
  - Standard maximum likelihood logistic regression (comparison)
- Adjusted models including age, sex, and both covariates
- Effect estimates reported as odds ratios with 95% confidence intervals

---

## Key Findings
- Religiosity was **not significantly associated** with lifetime suicidality
  - OR per 1 SD increase in religiosity (Firth): 1.14  
    (95% CI: 0.62–2.11)
- Results were consistent across:
  - Penalized and standard logistic regression
  - Unadjusted and adjusted models
- Descriptive plots suggested higher event rates in higher religiosity tertiles, but these patterns were not statistically reliable given the small sample size

---

## Interpretation
Within this NSAL Bipolar I subset, religiosity neither protected against nor increased lifetime suicidality in a statistically meaningful way. These findings suggest that clinicians should assess suicide risk directly rather than inferring risk based on religious engagement alone.

---

## Limitations
- Small analytic sample and limited number of events
- Cross-sectional measurement of key variables
- Composite religiosity index assumes equal weighting of components
- Results may not generalize beyond the NSAL Bipolar I subgroup

---

## Skills Demonstrated
- Complex survey data filtering and cohort construction
- Composite index development and standardization
- Bias-reduced logistic regression (Firth correction)
- Careful handling of small-sample inference
- Model comparison and covariate adjustment
- Clear statistical interpretation and reporting

---

## Files
- `Final_Project_Data_Analysis.pdf` – Full analytical report
- `Final_Project_DA.R` – Reproducible R code
- `Final_Project_DA_LaTeX.tex` – LaTeX source for report generation

