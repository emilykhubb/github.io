# Linear Regression Modeling with Transformations

## Overview
This project explores the relationship between housing prices and square footage using linear regression techniques. Using a dataset of over 20,000 home sales in King County, Washington, multiple regression models were developed, evaluated, and compared to identify the most predictive and statistically sound approach.

The analysis emphasizes model interpretation, diagnostic checking, and the use of transformations to address violations of linear regression assumptions.

---

## Data
- Source: King County housing dataset (Kaggle)
- Observations: ~20,000 homes
- Key variables:
  - Price (sale price of home)
  - Square footage (interior living area)
  - Number of bedrooms

---

## Methods
- Exploratory data analysis using histograms, boxplots, and scatterplots
- Simple linear regression (price ~ square footage)
- Log-transformed models:
  - log(price) ~ square footage
  - price ~ log(square footage)
  - log(price) ~ log(square footage)
- Model diagnostics:
  - Residuals vs. fitted plots
  - Q–Q plots
  - Lilliefors test for normality
  - ACF plots for independence
- Model comparison using adjusted R²
- Multiple regression with an additional covariate (bedrooms)

---

## Key Findings
- Housing price and square footage exhibit a clear positive linear relationship
- Log transformations reduce skewness and improve interpretability, though some assumptions remain violated
- Adding the number of bedrooms as a second covariate substantially improves model fit
- The final multiple regression model achieves the highest adjusted R², indicating the strongest predictive performance

---

## Skills Demonstrated
- Linear regression modeling and interpretation
- Use of log and log–log transformations
- Regression diagnostics and assumption checking
- Model comparison and selection
- Clear statistical communication and reporting

---

## Files
- `HW1_Data_Analysis.pdf` – Full analytical report
- `DA_HW1.R` – Reproducible R code for analysis
- `HW1_DA_LaTeX.tex` – LaTeX source for report generation

