-- What are the total sales revenue and total transactions overall?
SELECT 
    SUM(quantity * price_per_unit) AS total_sales_revenue,
    COUNT(*) AS total_transactions_overall
FROM
    cafe_sales_clean;

-- Which item sells the most (by quantity and by revenue)?
-- by quantity
SELECT 
    item, SUM(quantity) AS total_quantity_sold
FROM
    cafe_sales_clean
GROUP BY item
ORDER BY total_quantity_sold DESC
LIMIT 1;

-- by revenue
SELECT 
    item, SUM(quantity * price_per_unit) AS total_revenue
FROM
    cafe_sales_clean
GROUP BY item
ORDER BY total_revenue DESC
LIMIT 1;

-- What is the most common payment method?
SELECT 
    payment_method, COUNT(*) AS payment_method_count
FROM
    cafe_sales_clean
WHERE
    payment_method IS NOT NULL
        AND payment_method <> 'UNKNOWN'
GROUP BY payment_method
ORDER BY payment_method_count DESC
LIMIT 1;


-- How many transactions came from each location (In-store vs Takeaway)?
SELECT 
    location, COUNT(*) AS location_count
FROM
    cafe_sales_clean
WHERE
    location <> 'UNKNOWN'
GROUP BY location;

-- Which item generates the most revenue per location?
WITH revenue_by_item AS (
SELECT 
    location,
    item,
    SUM(quantity * price_per_unit) AS total_revenue
FROM
    cafe_sales_clean
WHERE
    location <> 'UNKNOWN'
        AND item <> 'UNKNOWN'
GROUP BY location , item
),
ranked AS (
SELECT location, item, total_revenue,
RANK() OVER (PARTITION BY location ORDER BY total_revenue DESC) AS rn
FROM revenue_by_item
)

SELECT 
    location, item, total_revenue
FROM
    ranked
WHERE
    rn = 1;

-- What is the average order value by payment method?
SELECT 
    payment_method,
    ROUND(AVG(quantity * price_per_unit), 2) AS avg_order_value
FROM
    cafe_sales_clean
WHERE
    payment_method <> 'UNKNOWN'
GROUP BY payment_method;


-- Which items are most popular per location?
WITH total_sales_per_location AS (
SELECT item, location, SUM(quantity) AS total_quantity
FROM cafe_sales_clean
WHERE item <> 'UNKNOWN' AND location <> 'UNKNOWN'
GROUP BY item, location
),
ranked AS (
SELECT *,
RANK() OVER (PARTITION BY location ORDER BY total_quantity DESC) AS rn
FROM total_sales_per_location
)
SELECT item, location, total_quantity
FROM ranked
WHERE rn = 1;

-- What is the busiest day/month for sales?
-- busiest month
SELECT 
    YEAR(transaction_date) AS order_year,
    MONTHNAME(transaction_date) AS order_month,
    COUNT(*) AS total_transactions
FROM
    cafe_sales_clean
WHERE
    transaction_date IS NOT NULL
        AND item <> 'UNKNOWN'
GROUP BY YEAR(transaction_date) , MONTH(transaction_date) , MONTHNAME(transaction_date)
ORDER BY total_transactions DESC;

-- busiest day
SELECT 
    YEAR(transaction_date) AS order_year,
    DAYNAME(transaction_date) AS order_day,
    COUNT(*) AS total_transactions
FROM
    cafe_sales_clean
WHERE
    transaction_date IS NOT NULL
        AND item <> 'UNKNOWN'
GROUP BY YEAR(transaction_date) , DAYNAME(transaction_date)
ORDER BY total_transactions DESC;
