SELECT 
    *
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

-- type cast the transaction_date to a DATE
SELECT 
    CAST(transaction_date AS DATE) AS transaction_date
FROM
    cafe_sales_clean;

-- check if quantity and prices per unit are positive
SELECT 
    quantity, price_per_unit
FROM
    cafe_sales_clean
WHERE
    quantity < 1;
