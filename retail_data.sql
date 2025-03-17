--				[ CLEANING ]

-- 1. [ Potential Irrelevant data ]
SELECT *
FROM retail_data rd 
LIMIT 20;

PRAGMA table_info(retail_data)

-- 2. [ Duplicate data ] | 3. [ Structural Errors - Naming conventions, typos, capitalization, notNULLs, extra spaces ] | 4. [ Missing Data & NULLs ] | 5. [ Standardize - Datatype, Numerics] | -- 6. [ Outliers ] | -- 7. [ Merge, Transform, Drop]
	-- data cleaning and transformations done in PowerQuery
		-- no nulls or erroneous values, typecasted multiple columns to datetime

--				[ ANALYSIS ]

-- checking years available
SELECT DISTINCT
    STRFTIME('%Y', transaction_date) AS year
FROM 
    retail_data rd 
ORDER BY 
    year;
-- check max and min date
SELECT MAX(transaction_date), MIN(transaction_date)
FROM retail_data rd 

-- 1. YTD, PYTD, Gross Sales, Discounts, Net Sales, Transactions, Quantity Sold
WITH reference_date AS (
    SELECT '2023-03-16' AS date --reference point 
),
ytd_data AS (
    -- Current Year-to-Date transactions (using 2021 as current year since max_transaction_date)
    SELECT 
        SUM(quantity * unit_price) AS gross_sales,
        SUM(discount_applied) AS total_discounts,
        SUM(quantity * unit_price - discount_applied) AS net_sales,
        COUNT(DISTINCT transaction_id) AS transaction_count,
        SUM(quantity) AS total_items_sold
    FROM 
        retail_data
    WHERE 
        STRFTIME('%Y', transaction_date) = '2021'
        AND STRFTIME('%m%d', transaction_date) <= STRFTIME('%m%d', (SELECT date FROM reference_date))
),
pytd_data AS (
    -- Prior Year-to-Date transactions (2020 data for same period)
    SELECT 
        SUM(quantity * unit_price) AS gross_sales,
        SUM(discount_applied) AS total_discounts,
        SUM(quantity * unit_price - discount_applied) AS net_sales,
        COUNT(DISTINCT transaction_id) AS transaction_count,
        SUM(quantity) AS total_items_sold
    FROM 
        retail_data
    WHERE 
        STRFTIME('%Y', transaction_date) = '2020'
        AND STRFTIME('%m%d', transaction_date) <= STRFTIME('%m%d', (SELECT date FROM reference_date))
)
-- Main query with YTD, PYTD comparison and growth metrics
SELECT 
    -- YTD metrics
    ytd.gross_sales AS ytd_gross_sales,
    ytd.total_discounts AS ytd_discounts,
    ytd.net_sales AS ytd_net_sales,
    ytd.transaction_count AS ytd_transactions,
    ytd.total_items_sold AS ytd_items_sold,
    -- PYTD metrics
    pytd.gross_sales AS pytd_gross_sales,
    pytd.total_discounts AS pytd_discounts,
    pytd.net_sales AS pytd_net_sales,
    pytd.transaction_count AS pytd_transactions,
    pytd.total_items_sold AS pytd_items_sold,
    -- YOY growth calculations
    CASE 
        WHEN pytd.net_sales = 0 THEN NULL
        ELSE ROUND((ytd.net_sales - pytd.net_sales) / pytd.net_sales * 100, 2)
    END AS net_sales_growth_pct,
    CASE 
        WHEN pytd.transaction_count = 0 THEN NULL
        ELSE ROUND((ytd.transaction_count * 1.0  - pytd.transaction_count) / pytd.transaction_count * 100, 2)
        --SQLite engine performs integer division before applying ROUND(), leading to truncation,need to multiply *1.0
    END AS transaction_count_growth_pct
FROM 
    ytd_data ytd, pytd_data pytd;

-- 2. Customer Retention by Membership Duration
SELECT 
    membership_years, 
    100.0 * COUNT(DISTINCT customer_id) FILTER (WHERE churned = 'Yes') / COUNT(DISTINCT customer_id) AS retention_rate
FROM 
    retail_data
GROUP BY 
    membership_years
ORDER BY 
    membership_years ASC;

-- 3. Product Performance Index(Combines sales, ratings, and returns to evaluate product performance) against Average Performance
WITH product_performance AS (
    SELECT 
        product_id, 
        (SUM(quantity * unit_price) * AVG(product_rating) / (1 + AVG(product_return_rate))) AS product_performance_index
    FROM retail_data
    GROUP BY product_id
),
average_performance AS (
    SELECT AVG(product_performance_index) AS avg_performance_index
    FROM product_performance
)
SELECT 
    p.product_id, 
    p.product_performance_index,
    a.avg_performance_index,
    CASE 
        WHEN p.product_performance_index > a.avg_performance_index THEN 'Above Average'
        WHEN p.product_performance_index < a.avg_performance_index THEN 'Below Average'
        ELSE 'Average'
    END AS performance_category
FROM product_performance p
CROSS JOIN average_performance a
ORDER BY p.product_performance_index DESC;

-- 3.5 Count of Above/Below Average Performance
WITH product_performance AS (
    SELECT 
        product_id, 
        (SUM(quantity * unit_price) * AVG(product_rating) / (1 + AVG(product_return_rate))) AS product_performance_index
    FROM retail_data
    GROUP BY product_id
),
average_performance AS (
    SELECT AVG(product_performance_index) AS avg_performance_index
    FROM product_performance
)
SELECT 
    CASE 
        WHEN p.product_performance_index > a.avg_performance_index THEN 'Above Average'
        WHEN p.product_performance_index < a.avg_performance_index THEN 'Below Average'
        ELSE 'Average'
    END AS performance_category,
    COUNT(*) AS product_count
FROM product_performance p
CROSS JOIN average_performance a --using a cross join because I want every productperformance to have it's own average performance for comparison
GROUP BY performance_category
ORDER BY product_count DESC;
-- 4. Sales Trends by Customer Age Group
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+' 
    END AS age_group, 
    SUM(total_sales) AS total_sales
FROM 
    retail_data
GROUP BY 
    age_group
ORDER BY 
    total_sales DESC;

-- 5. Effectiveness of discounts across income brackets.
SELECT 
    income_bracket, 
    AVG(avg_discount_used) AS avg_discount_used
FROM 
    retail_data
GROUP BY 
    income_bracket;

-- 6. Product Return Rate by Category
SELECT 
    product_category, 
    SUM(total_returned_items) * 100.0 / SUM(total_items_purchased) AS return_rate
FROM 
    retail_data
GROUP BY 
    product_category;

-- 7. Sales Contribution by Payment Method
SELECT 
    payment_method, 
    SUM(total_sales) AS sales_contribution
FROM 
    retail_data
GROUP BY 
    payment_method;

-- 8. Promotion Effectiveness - Revenue generated during promotions compared to the average.
SELECT 
    promotion_id, 
    (SUM(total_sales) - AVG(total_sales)) * 100.0 / AVG(total_sales) AS promotion_effectiveness
FROM 
    retail_data
WHERE 
    promotion_id IS NOT NULL
GROUP BY 
    promotion_id;

-- 9. Customer Engagement Score
SELECT 
    customer_id, 
    (email_subscriptions + app_usage + website_visits + social_media_engagement) AS engagement_score
FROM 
    retail_data;

-- 10. Preferred Stores
SELECT 
    store_location, 
    COUNT(transaction_id) AS total_visits
FROM 
    retail_data
GROUP BY 
    store_location
ORDER BY 
    total_visits DESC;

-- 11. Seasonal Sales Trends
SELECT 
    season, 
    SUM(total_sales) AS seasonal_sales
FROM 
    retail_data
GROUP BY 
    season;

-- 12. Seasonal Customer Acquisition
SELECT 
    season, 
    COUNT(DISTINCT customer_id) AS new_customers
FROM 
    retail_data
WHERE 
    membership_years = 0
GROUP BY 
    season
ORDER BY 
    new_customers DESC;

-- 13. Product Aging & Return Rates
SELECT 
    product_id, 
    (JULIANDAY('now') - JULIANDAY(product_manufacture_date)) AS product_age_days,
    SUM(total_returned_items) * 100.0 / SUM(total_items_purchased) AS return_rate
FROM 
    retail_data
GROUP BY 
    product_id
ORDER BY 
    product_age_days DESC;

-- 14. Education 
WITH customer_summary AS (
    SELECT 
        education_level,
        COUNT(DISTINCT customer_id) AS total_customers,
        AVG(income_bracket) AS avg_income,
        SUM(total_sales) AS total_revenue,
        AVG(avg_purchase_value) AS avg_purchase_value,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
        SUM(CASE WHEN churned = 'No' THEN 1 ELSE 0 END) AS active_customers,
        ROUND(100.0 * SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) / COUNT(customer_id), 2) AS churn_rate
    FROM retail_data
    GROUP BY education_level
)
SELECT 
    education_level,
    total_customers,
    avg_income,
    total_revenue,
    avg_purchase_value,
    churned_customers,
    active_customers,
    churn_rate
FROM customer_summary
ORDER BY total_revenue DESC;

/* Wanted Average Purchase Interval: Average time gap between two purchases for each customer. Customers only have 1 transaction, no output

WITH purchase_gaps AS (
    SELECT 
        customer_id,
        transaction_date,
        LAG(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date) AS prev_transaction_date
    FROM retail_data
)
SELECT 
    customer_id,
    AVG(JULIANDAY(transaction_date) - JULIANDAY(prev_transaction_date)) AS avg_purchase_interval
FROM purchase_gaps
WHERE prev_transaction_date IS NOT NULL
GROUP BY customer_id;

*/
