# Machine Learning Classification Models

## Overview
This project compares multiple machine learning classification methods to predict consumer brand choice between Citrus Hill and Minute Maid orange juice. Using a dataset with substantial multicollinearity, tree-based methods and support vector machines are evaluated to determine which approach provides the strongest predictive performance on unseen data.

---

## Data
- Source: Orange Juice (OJ) dataset from the ISLR package
- Response variable:
  - Purchase decision (Citrus Hill vs Minute Maid)
- Predictors:
  - Prices, discounts, promotions
  - Brand loyalty measures
  - Store and temporal variables
- Key challenge:
  - Severe multicollinearity among predictors

---

## Methods
The following classification models were trained and evaluated using a train/test split:

- Decision Trees:
  - Unpruned decision tree
  - Pruned decision tree (cross-validation)
- Ensemble Methods:
  - Bagging
  - Random forests
  - Boosted trees
- Support Vector Machines:
  - Linear SVM
  - Non-linear (radial) SVM

### Model Evaluation
- Confusion matrices
- Accuracy and misclassification rates
- Out-of-sample performance comparison

---

## Key Findings
- The linear SVM achieved the highest test accuracy (0.837)
- Tree-based ensemble methods performed competitively but slightly worse
- The non-linear SVM underperformed relative to the linear model
- Results suggest the underlying decision boundary is approximately linear
- Model selection was guided by empirical performance rather than model complexity

---

## Skills Demonstrated
- Machine learning classification
- Decision trees and ensemble methods
- Support vector machines (linear and non-linear)
- Handling multicollinearity
- Model comparison and evaluation
- Interpretation of predictive performance
- Analytical decision-making

---

## Files
- `HW5_Data_Analysis.pdf` – Full analytical report
- `DA_HW5.R` – Reproducible R code
- `HW5_DA_LaTeX.tex` – LaTeX source for report generation

