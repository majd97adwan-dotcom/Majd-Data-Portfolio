-- =====================================================
-- Project: Sales Data Cleaning & Transformation Pipeline
-- Database: MySQL 8.0+
-- =====================================================

-- 1. DATABASE SETUP

CREATE DATABASE IF NOT EXISTS sales_db;

USE sales_db;


-- 2. CREATE STAGING TABLE

CREATE TABLE IF NOT EXISTS raw_sales_staging (
    raw_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    raw_phone VARCHAR(50),
    product_code VARCHAR(50),
    amount_str VARCHAR(50),
    status_code VARCHAR(50),
    created_at_text VARCHAR(50)
);


-- 3. CREATE CLEAN TARGET TABLE

CREATE TABLE IF NOT EXISTS clean_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    clean_phone VARCHAR(50),
    product_code VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(20) DEFAULT 'UNKNOWN',
    order_date DATE NOT NULL
);


-- 4. DATA CLEANING, TRANSFORMATION & LOADING

INSERT INTO clean_orders (
    customer_name,
    clean_phone,
    product_code,
    amount,
    order_status,
    order_date
)

WITH parsed_data AS (
    SELECT
        raw_id,

        NULLIF(
            LOWER(TRIM(customer_name)),
            ''
        ) AS clean_customer_name,

        NULLIF(
            REGEXP_REPLACE(
                TRIM(raw_phone),
                '[^0-9]',
                ''
            ),
            ''
        ) AS clean_phone,

        NULLIF(
            TRIM(product_code),
            ''
        ) AS clean_product_code,

        CASE
            WHEN TRIM(amount_str)
                 REGEXP '^[+-]?[0-9]+([.][0-9]{1,2})?$'
            THEN CAST(
                TRIM(amount_str) AS DECIMAL(10, 2)
            )

            WHEN REPLACE(
                     REPLACE(
                         REPLACE(TRIM(amount_str), '$', ''),
                         ',',
                         ''
                     ),
                     ' ',
                     ''
                 )
                 REGEXP '^[+-]?[0-9]+([.][0-9]{1,2})?$'
            THEN CAST(
                REPLACE(
                    REPLACE(
                        REPLACE(TRIM(amount_str), '$', ''),
                        ',',
                        ''
                    ),
                    ' ',
                    ''
                ) AS DECIMAL(10, 2)
            )

            ELSE NULL
        END AS clean_amount,

        COALESCE(
            NULLIF(UPPER(TRIM(status_code)), ''),
            'UNKNOWN'
        ) AS clean_status,

        CASE
            WHEN TRIM(created_at_text)
                 REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(
                TRIM(created_at_text),
                '%Y-%m-%d'
            )

            WHEN TRIM(created_at_text)
                 REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(
                TRIM(created_at_text),
                '%m/%d/%Y'
            )

            ELSE NULL
        END AS parsed_date,

        TRIM(created_at_text) AS original_date

    FROM raw_sales_staging
)

SELECT
    clean_customer_name,
    clean_phone,
    clean_product_code,
    clean_amount,
    clean_status,
    parsed_date

FROM parsed_data

WHERE clean_customer_name IS NOT NULL
  AND clean_product_code IS NOT NULL
  AND clean_amount > 0
  AND parsed_date IS NOT NULL

  AND (
      (
          original_date REGEXP
          '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'

          AND DATE_FORMAT(
              parsed_date,
              '%Y-%m-%d'
          ) = original_date
      )

      OR

      (
          original_date REGEXP
          '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'

          AND DATE_FORMAT(
              parsed_date,
              '%m/%d/%Y'
          ) = original_date
      )
  );


-- =====================================================
-- 5. DATA VALIDATION
-- =====================================================

-- Check total number of cleaned records

SELECT
    COUNT(*) AS total_clean_orders
FROM clean_orders;


-- Check missing or invalid customer names

SELECT
    COUNT(*) AS invalid_customer_names
FROM clean_orders
WHERE customer_name IS NULL
   OR TRIM(customer_name) = '';


-- Check missing product codes

SELECT
    COUNT(*) AS missing_product_codes
FROM clean_orders
WHERE product_code IS NULL
   OR TRIM(product_code) = '';


-- Check invalid amounts

SELECT
    COUNT(*) AS invalid_amounts
FROM clean_orders
WHERE amount IS NULL
   OR amount <= 0;


-- Check missing order dates

SELECT
    COUNT(*) AS missing_order_dates
FROM clean_orders
WHERE order_date IS NULL;


-- Check order status distribution

SELECT
    order_status,
    COUNT(*) AS number_of_orders
FROM clean_orders
GROUP BY order_status
ORDER BY number_of_orders DESC;


-- Preview the cleaned data

SELECT *
FROM clean_orders
ORDER BY order_id
LIMIT 100;
