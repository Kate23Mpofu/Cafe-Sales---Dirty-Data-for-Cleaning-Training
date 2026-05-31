-- What are the total sales revenue and total transactions overall?
SELECT 
    SUM(quantity * price_per_unit) AS total_sales_revenue,
    COUNT(*) AS total_transactions_overall
FROM
    cafe_sales_clean;

-- Which item sells the most (by quantity and by revenue)?
SELECT 
    item,
    SUM(quantity) AS total_quantity_sold,
    SUM(quantity * price_per_unit) AS total_revenue
FROM
    cafe_sales_clean
GROUP BY item
ORDER BY total_quantity_sold DESC , total_revenue DESC;

-- What is the most common payment method?
SELECT 
    payment_method, COUNT(*) AS payment_method_count
FROM
    cafe_sales_clean
WHERE
    payment_method != 'UNKNOWN'
GROUP BY payment_method
ORDER BY payment_method_count DESC;


-- How many transactions came from each location (In-store vs Takeaway)?
SELECT 
    location, COUNT(location) AS location_count
FROM
    cafe_sales_clean
WHERE
    location != 'UNKNOWN'
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
    location != 'UNKNOWN'
        AND item != 'UNKNOWN'
GROUP BY location , item
),
ranked AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY location ORDER BY total_revenue DESC) AS rn
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
    payment_method != 'UNKNOWN'
GROUP BY payment_method;


-- Which items are most popular per location?
WITH total_sales_per_location AS (
SELECT item, location, SUM(quantity * price_per_unit) AS total_sales
FROM cafe_sales_clean
WHERE item != 'UNKNOWN' AND location != 'UNKNOWN'
GROUP BY item, location
),
ranked AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY location ORDER BY total_sales DESC) AS rn
FROM total_sales_per_location
)
SELECT item, location, total_sales
FROM ranked
WHERE rn = 1;

-- What is the busiest day/month for sales?
-- busiest month
SELECT 
    EXTRACT(MONTH FROM transaction_date) AS order_month,
    SUM(quantity * price_per_unit) AS total_sales
FROM
    cafe_sales_clean
WHERE
    transaction_date IS NOT NULL
        AND item != 'UNKNOWN'
GROUP BY order_month
ORDER BY total_sales DESC;

-- busiest day
SELECT 
    DAYNAME(transaction_date) AS order_day,
    SUM(quantity * price_per_unit) AS total_sales
FROM
    cafe_sales_clean
WHERE
    transaction_date IS NOT NULL
        AND item != 'UNKNOWN'
GROUP BY order_day
ORDER BY total_sales DESC;