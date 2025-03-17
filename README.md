--- SQL CLEANING & ANALYSIS -> []()
Retail Data Analysis: Customer Behavior & Sales Patterns
<h1 align="center">Introduction</h1>

This project delves into a comprehensive retail dataset with a million rows, 78 columns to uncover actionable intelligence that can drive business growth and enhance customer experience. 
The dataset consists of 1 retail_data tables containing columns: 
<img src=  width="300" >

## Business Task & Objectives:
This analysis transforms extensive retail sales and customer data into strategic insights to optimize retail operations and marketing strategies. Using SQL, we explore key business questions including:

- How are we performing this year compared to the same period last year?
- What factors most strongly influence customer purchasing behavior?
- How do loyalty programs impact customer retention and spending patterns?
- What indicators help predict customer churn and lifetime value?
- Is our sales growth coming from more transactions or higher transaction values?
- Are we discounting more or less than the same period last year?

## Tools:
Data cleaning and Analysis using SQL

## Data Source:
[Retail_data](https://www.kaggle.com/datasets/utkalk/large-retail-data-set-for-eda/data)

<h1 align="center">Insights</h1>
Our platform serves a diverse customer base across various age groups, generating total seasonal sales of approximately $5,059,786,766.14, with Winter showing the highest seasonal sales at $1,266,673,200.10. 
Customer retention appears to stabilize around an average rate of 50% across membership years, reflecting consistency in engagement. 
Payment methods contribute nearly evenly to sales, with Credit Cards leading slightly at $1,268,594,134.71.

## Demographic Insights and Purchasing Behavior
- Income bracket analysis shows relatively consistent discount usage across all income segments with an average discount usage of 25% 
- Customers aged (50+) are our highest-value segment, generating ($2,366,681,873.20) in total sales with (36-50) age group follows with ($1,222,789,701.01) in sales.
- Younger demographics show lower but substantial contributions: (26-35) age group ($816,430,757.71) and (18-25) age group ($650,157,433.22)
This age distribution highlights the importance of our mature customer base, with over 50% of revenue coming from customers aged 50+. This suggests opportunities for targeted marketing to younger demographics to build long-term customer value.
The uniform discount utilization across income brackets suggests our pricing and promotion strategies appeal equally to all customer segments regardless of income level.

## Product Performance and Category
- 4,851 products performing above average (PPI > 600,768.85)
- 5,148 products performing below average (PPI < 600,768.85)
-Top performing products show exceptional results:
  - Product #8325: PPI of 961,676.89 (60% above average)
  - Product #5427: PPI of 947,950.41 (58% above average)
  - Product #5181: PPI of 925,316.14 (54% above average)
  - Product #8756: PPI of 915,409.87 (52% above average)
  - Product #6019: PPI of 914,851.33 (52% above average)
- Return rates are very consistent across product categories with an average return rate of 1.8%.
This uniformity in return rates suggests standardized quality across categories, though there are individual products with higher return rates that warrant attention, such as Product #5179 with a 2.16% return rate.

## Product Basket
- Payment method analysis shows balanced contributions across transaction types with Credit Cards, Cash, Mobile Payments, and Debit Cards all making up about a quarter of the sales.
- Product age analysis reveals potential correlation between product age and return rates with odler products having higher return rates.

## Recommendations
- Age-Based Marketing Strategy: Develop targeted campaigns to increase engagement with younger demographics (18-35) while maintaining strong relationships with 50+ customers who drive the majority of our revenue.
- Evaluate the 5,148 below-average performing products to identify candidates for improvement or potential discontinuation, focusing resources on top performers.
- Retention Program Enhancement: Implement a comprehensive retention strategy to improve the consistent 50% retention rate across all membership years.
- Restructure or eliminate underperforming promotions like #10, while scaling successful campaigns like #12 and #9 to maximize promotional ROI.
- Product Lifecycle Management: Establish a systematic review process for products exceeding 2,000 days in market, particularly for those showing elevated return rates like Product #5179 (highest return rate).

