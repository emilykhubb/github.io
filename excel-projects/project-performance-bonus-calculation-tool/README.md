# Project Performance & Bonus Calculation Tool (Excel)

## Overview

This Excel-based model provides a structured, transparent method for evaluating project performance and calculating project-level bonuses. The tool blends qualitative leadership evaluations with quantitative performance metrics using adjustable weighted scoring.

The model separates inputs from calculated outputs and allows leadership to modify weighting logic through an Admin tab, ensuring flexibility while maintaining consistency.

---

## Purpose

- Standardize project performance evaluation
- Combine subjective leadership assessments with objective financial metrics
- Improve transparency and consistency in bonus decisions
- Enable structured, repeatable compensation logic
- Support future reporting and performance tracking

---

## Model Structure

### 1️⃣ Projects Tab (Data Entry & Outputs)

This tab captures project-level inputs and automatically calculates performance scores and bonus recommendations.

#### Basic Information
- Project Name
- Designer

#### Subjective Inputs (1–5 Scale)
- Customer Satisfaction Average (optional)
- Boss Q1 – Communication
- Boss Q2 – Design Quality
- Boss Q3 – Organization
- Boss Q4 – Problem Solving
- Boss Q5 – Professionalism
- Mistakes (total count)

#### Objective Inputs
- Hours (total labor hours)
- Profit ($)
- Target Profit ($)
- Target Efficiency (USD/hour)

---

### 2️⃣ Scoring Logic

All scores are normalized to a 0–1 scale for comparability.

#### Subjective Variable (Sub Var)
Weighted combination of:
- Customer Score (if available; Customer Average converted to 0–1)
- Boss Score (average of Q1–Q5, converted to 0–1)
- Mistake Score (based on normalized mistake rate)

#### Objective Variable (Obj Var)
Weighted combination of:
- Profit Score (actual profit vs target profit, capped at 1)
- Efficiency Score (actual profit per hour vs target efficiency, capped at 1)

#### Final Score
Calculated as a weighted blend of subjective and objective performance:

Final Score = (Sub Var × Sub Var Weight) + (Obj Var × Obj Var Weight)

#### Bonus Calculation
Bonus is calculated using the maximum allowable bonus and the final score:

Bonus = Final Score × Max Bonus

---

## Mistake Normalization

Mistakes are normalized per a configurable number of hours (default: 50 hours):

Mistake Rate = (Mistakes ÷ Hours) × Normalization Hours

The Mistake Score decreases as mistake rate increases and reaches zero at the Admin-defined **Max Mistake Rate (per Normalization Hours)** threshold.

---

## Admin Tab (Configuration Controls)

The Admin tab allows leadership to adjust:

- Max Bonus ($)
- Sub Var Weight
- Obj Var Weight
- Customer Survey Weight
- Boss Evaluation Weight
- Mistakes Weight
- Profit Weight
- Efficiency Weight
- Normalization Hours
- Max Mistake Rate (per normalization hours)

All weight groupings must sum to **1.00** to maintain scoring integrity.

---

## Boss Evaluation Rubric (1–5 Scale)

Each project is scored across five structured leadership dimensions:

| Category        | Question Focus |
|----------------|----------------|
| Communication  | Client communication and relationship management |
| Design         | Quality, attention to detail, execution |
| Organization   | Timeline management and project tracking |
| Problem Solving| Adaptability and handling unexpected issues |
| Professionalism| Ownership, accountability, follow-through |

Scoring Definitions:  
1 – Poor  
2 – Below Average  
3 – Meets Expectations  
4 – Above Average  
5 – Excellent  

---

## What’s Included

- **Excel Workbook**  
  Full scoring model with anonymized project and designer data.

- **Data Dictionary**  
  Field-level definitions of all variables, inputs, and calculated outputs.

- **How-To Guide**  
  Step-by-step instructions for entering project data and interpreting results.

- **Rubric Reference Sheet**  
  Structured evaluation criteria for consistent leadership scoring.

- **Screenshots**  
  Preview of scoring logic and final output view.

---

## Design Principles

- Clear separation of editable input cells and protected formulas
- Color-coded structure for usability
- Adjustable weighting system
- Transparent scoring methodology
- Built for scalability and consistency

---

## Tools Used

Microsoft Excel  
- Structured Tables  
- Weighted scoring formulas
- Conditional Formatting  
- Data Validation  
- Dynamic calculations
