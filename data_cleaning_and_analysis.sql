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
    
SELECT 
    *
FROM
    cafe_sales_clean;
