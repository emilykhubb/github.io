# Regularization and Dimensionality Reduction

## Overview
This project explores techniques for handling high-dimensional and highly correlated data using regularization and dimensionality reduction methods. Ridge regression, lasso regression, and principal component analysis (PCA) are applied to two real-world datasets to improve model stability, interpretability, and insight extraction.

---

## Part 1: Regularized Logistic Regression for Brand Choice

### Objective
To predict consumer orange juice brand choice (Minute Maid vs. Citrus Hill) while addressing multicollinearity among price, promotion, and loyalty variables.

### Data
- Source: Orange Juice (OJ) dataset from the ISLR package
- Response variable:
  - Binary purchase outcome (MM vs. CH)
- Predictors:
  - Prices, discounts, promotional indicators
  - Brand loyalty measures
  - Store and temporal indicators

### Methods
- Binary logistic regression
- Ridge regression (L2 regularization)
- Lasso regression (L1 regularization)
- Cross-validation to select optimal λ
- Train/test split for model evaluation
- Performance metrics:
  - Accuracy
  - Misclassification rate
  - Mean squared error (MSE)
  - Confusion matrices

### Key Findings
- Strong multicollinearity exists among pricing and promotion variables
- Lasso regression produces a simpler model by selecting a reduced set of predictors
- Brand loyalty is the most influential factor in predicting purchase choice
- Lasso slightly outperforms ridge in both accuracy and MSE

---

## Part 2: Principal Component Analysis of Crime Data

### Objective
To reduce dimensionality and uncover underlying structure in correlated crime data across U.S. states.

### Data
- Source: `USArrests` dataset
- Variables:
  - Murder, Assault, Urban Population, Rape

### Methods
- Principal component analysis with scaling
- Variance explained assessment
- Interpretation of component loadings
- Biplot visualization of states and variable contributions

### Key Findings
- The first two principal components explain approximately 87% of total variance
- PC1 captures overall crime intensity
- PC2 reflects the influence of urbanization on crime patterns
- PCA provides interpretable structure not evident in the original variables

---

## Skills Demonstrated
- Regularized regression (ridge and lasso)
- Cross-validation and model comparison
- Multicollinearity handling
- Binary classification evaluation
- Dimensionality reduction with PCA
- Interpretation of loadings and biplots
- Analytical judgment and model selection

---

## Files
- `HW4_Data_Analysis.pdf` – Full analytical report
- `DA_HW4.R` – Reproducible R code
- `HW4_DA_LaTeX.tex` – LaTeX source for report generation

