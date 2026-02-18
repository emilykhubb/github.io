# Data Dictionary

## Projects Tab — Dictionary

| Variable | Definition |
|---|---|
| Project Name | Name or identifier of the project. |
| Designer | Designer responsible for the project. |
| Customer Average | Average customer survey score on a 1–5 scale; may be left blank if no survey is completed. |
| Boss Q1 | Score for client communication and relationship management (1–5). |
| Boss Q2 | Score for design quality, attention to detail, and execution (1–5). |
| Boss Q3 | Score for organization, timeline management, and project tracking (1–5). |
| Boss Q4 | Score for problem solving and adaptability during the project (1–5). |
| Boss Q5 | Score for professionalism, accountability, and follow-through (1–5). |
| Mistakes | Total number of mistakes recorded during the project. |
| Hours | Total labor hours spent on the project. |
| Profit | Total profit generated from the project (in USD). |
| Target Profit | Expected or target profit for the project (in USD). |
| Target Efficiency | Expected profit per hour for the project (USD/hour). |
| Boss Average | Average of Boss Q1–Q5 scores (1–5 scale). |
| Boss Score | Boss Average converted to a 0–1 scale. |
| Customer Score | Customer Average converted to a 0–1 scale; blank if no survey is provided. |
| Mistake Rate | Number of mistakes normalized to a standard time unit (per 50 hours). |
| Mistake Score | Score from 0–1 reflecting mistake performance, where fewer mistakes result in a higher score. |
| Profit Score | Score from 0–1 comparing actual profit to target profit, capped at 1. |
| Efficiency Score | Score from 0–1 comparing actual efficiency (profit per hour) to target efficiency, capped at 1. |
| Sub Var | Weighted subjective score combining customer, boss, and mistake performance. |
| Obj Var | Weighted objective score combining profit and efficiency performance. |
| Final Score | Overall project score (0–1) based on weighted subjective and objective performance. |
| Bonus | Recommended bonus amount calculated as Final Score multiplied by Max Bonus. |

---

## Admin Tab — Dictionary

| Field | Definition |
|---|---|
| Max Bonus ($) | Maximum bonus amount that can be awarded for a single project. |
| Sub Var Weight | Weight assigned to the subjective score in the final score calculation. |
| Obj Var Weight | Weight assigned to the objective score in the final score calculation. |
| Customer Survey Weight | Weight of the customer score within the subjective variable. |
| Boss Evaluation Weight | Weight of the boss evaluation within the subjective variable. |
| Mistakes Weight | Weight of the mistake score within the subjective variable. |
| Profit Weight | Weight of the profit score within the objective variable. |
| Efficiency Weight | Weight of the efficiency score within the objective variable. |
| Normalization Hours | Standard number of hours used to normalize mistakes (default is 50 hours). |
| Max Mistake Rate (per Normalization Hours) | Threshold for mistakes at which the mistake score reaches zero. |
