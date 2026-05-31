SELECT 
    *
FROM
    dirty_cafe_sales;


SELECT 
    COUNT(*) AS total
FROM
    dirty_cafe_sales;

-- rename columns to standardize them
ALTER TABLE dirty_cafe_sales
RENAME COLUMN `Transaction ID` TO transaction_id;

ALTER TABLE dirty_cafe_sales
RENAME COLUMN `Item` TO item;

ALTER TABLE dirty_cafe_sales
RENAME COLUMN `Quantity` TO quantity;

ALTER TABLE dirty_cafe_sales
RENAME COLUMN `Price Per Unit` TO price_per_unit;

ALTER TABLE dirty_cafe_sales
RENAME COLUMN `Total Spent` TO total_spent;

ALTER TABLE dirty_cafe_sales
RENAME COLUMN `Payment Method` TO payment_method;

ALTER TABLE dirty_cafe_sales
RENAME COLUMN `Location` TO location;

ALTER TABLE dirty_cafe_sales
RENAME COLUMN `Transaction Date` TO transaction_date;

-- create a staging table
CREATE TABLE cafe_sales_staging (LIKE dirty_cafe_sales);

INSERT INTO cafe_sales_staging
SELECT *
FROM dirty_cafe_sales;

-- check if the staging table has been populated
SELECT 
    *
FROM
    cafe_sales_staging;

-- use cafe_sales_staging
-- check and remove duplicates, if any are available
CREATE TABLE cafe_sales_clean AS -- new clean table with no duplicates
-- create CTE to check for duplicates
WITH duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id, item, quantity,
                            price_per_unit, total_spent,
                            payment_method, location, transaction_date
           ) AS dp
    FROM cafe_sales_staging
)
SELECT
    transaction_id,
    item,
    quantity,
    price_per_unit,
    total_spent,
    payment_method,
    location,
    transaction_date
FROM duplicates
WHERE dp = 1;

-- use cafe_sales_clean
-- check for multiple missing values
SELECT 
    *
FROM
    cafe_sales_clean
WHERE
    (item IS NULL OR item = '')
        AND (payment_method IS NULL
        OR payment_method = '')
        AND (location IS NULL OR location = '');

-- drop columns that have a lot of missing information
DELETE FROM cafe_sales_clean 
WHERE
    (item IS NULL OR item = '')
    AND (payment_method IS NULL
    OR payment_method = '')
    AND (location IS NULL OR location = '');
    
-- identify missing total_spent amounts
SELECT 
    quantity, price_per_unit, total_spent
FROM
    cafe_sales_clean
WHERE
    total_spent IS NULL OR total_spent = ''
        OR total_spent = 'ERROR'
        OR total_spent = 'UNKNOWN';

-- handle missing total_spent amounts
-- the total_spent is quantity * price_per_unit

SELECT 
    *
FROM
    cafe_sales_clean
WHERE
    quantity IS NULL OR quantity = ''
        OR quantity = 'ERROR'
        OR quantity = 'UNKNOWN'
;

-- find missing quantity
SELECT 
    *
FROM
    cafe_sales_clean
WHERE
    price_per_unit IS NULL
        OR price_per_unit = ''
        OR price_per_unit = 'ERROR'
        OR price_per_unit = 'UNKNOWN'
;

UPDATE cafe_sales_clean 
SET 
    total_spent = (quantity * price_per_unit)
WHERE
    total_spent IS NULL OR total_spent = ''
        OR total_spent = 'ERROR'
        OR total_spent = 'UNKNOWN';
        
-- find missing payment methods
SELECT 
    *
FROM
    cafe_sales_clean
WHERE
    payment_method IS NULL
        OR payment_method = ''
        OR payment_method = 'ERROR'
        OR payment_method = 'UNKNOWN'
;

-- handle missing payment methods
UPDATE cafe_sales_clean 
SET 
    payment_method = 'UNKNOWN'
WHERE
    payment_method IS NULL
        OR payment_method = ''
        OR payment_method = 'ERROR'
        OR payment_method = 'UNKNOWN'
;

-- find missing locations
SELECT 
    *
FROM
    cafe_sales_clean
WHERE
    location IS NULL OR location = ''
        OR location = 'ERROR'
        OR location = 'UNKNOWN'
;

-- handle missing locations
UPDATE cafe_sales_clean 
SET 
    location = 'UNKNOWN'
WHERE
    location IS NULL OR location = ''
        OR location = 'ERROR'
        OR location = 'UNKNOWN'
;

-- find missing dates
SELECT 
    *
FROM
    cafe_sales_clean
WHERE
    transaction_date IS NULL
        OR transaction_date = ''
        OR transaction_date = 'ERROR'
        OR transaction_date = 'UNKNOWN'
;

-- handle missing dates
UPDATE cafe_sales_clean 
SET 
    transaction_date = NULL
WHERE
    transaction_date IS NULL
        OR transaction_date = ''
        OR transaction_date = 'ERROR'
        OR transaction_date = 'UNKNOWN'
;

-- check if quantity and prices per unit are positive
SELECT 
    quantity, price_per_unit
FROM
    cafe_sales_clean
WHERE
    quantity < 1;

SELECT 
    *
FROM
    cafe_sales_clean;


-- add constraints
ALTER TABLE cafe_sales_clean MODIFY total_spent DOUBLE; 
ALTER TABLE cafe_sales_clean MODIFY transaction_date DATE;

-- final comparison between cafe_sales_staging and cafe_sales_clean
SELECT 
    COUNT(*)
FROM
    cafe_sales_staging;

SELECT 
    COUNT(*)
FROM
    cafe_sales_clean;

SELECT (9006 - 8984) AS rows_removed_count;

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
