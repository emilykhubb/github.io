# Unsupervised Learning: Clustering Analysis

## Overview
This project applies unsupervised learning techniques to identify patterns in U.S. state crime and urbanization data. Hierarchical clustering and K-means clustering are implemented and compared to assess how different distance metrics and clustering strategies influence group formation and interpretability.

---

## Data
- Source: `USArrests` dataset
- Variables:
  - Murder arrests (per 100,000)
  - Assault arrests (per 100,000)
  - Rape arrests (per 100,000)
  - Percent urban population
- Preprocessing:
  - Z-score standardization applied to all variables

---

## Methods

### Hierarchical Clustering
- Distance metric: Euclidean
- Linkage methods:
  - Complete linkage
  - Average linkage
- Dendrogram visualization
- Clusters formed by cutting the tree at k = 4
- Interpretation of crime intensity and urbanization profiles by cluster

### K-Means Clustering
- Optimal number of clusters selected using:
  - Gap statistic (logW and ±1 SE)
  - Elbow method (within-cluster sum of squares)
- Final model:
  - k = 4 clusters
- Visualization of clusters in PCA space

---

## Key Findings
- Both clustering methods produce similar high-level groupings of states
- Differences emerge for borderline states due to methodological distinctions
- Hierarchical clustering makes irreversible merge decisions
- K-means assigns observations relative to centroids
- PCA visualization shows that the first two components explain approximately 87% of total variance

---

## Skills Demonstrated
- Unsupervised learning
- Hierarchical clustering
- K-means clustering
- Distance metrics and linkage methods
- Cluster validation (Gap statistic, elbow method)
- PCA-based visualization
- Interpretation of clustering results
- Analytical comparison of modeling approaches

---

## Files
- `HW6_Data_Analysis.pdf` – Full analytical report
- `DA_HW6.R` – Reproducible R code
- `HW6_DA_LaTeX.tex` – LaTeX source for report generation

