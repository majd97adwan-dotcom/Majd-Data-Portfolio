Sales Data Cleaning & Transformation Pipeline (MySQL)

Project Overview

This project demonstrates how SQL can be used to clean and transform raw sales data into a structured dataset suitable for analysis.

Business Scenario

Raw sales data may contain missing values, inconsistent formatting, invalid dates, and incorrect monetary values. This project applies data cleaning rules to improve data quality.

Tools Used

- MySQL 8.0+
- SQL
- Common Table Expressions (CTEs)
- Data Validation

Data Cleaning Steps

- Standardize customer names using "LOWER()" and "TRIM()".
- Clean phone numbers by removing non-numeric characters.
- Validate monetary values and convert them to "DECIMAL".
- Standardize order statuses and handle missing values.
- Convert supported date formats into proper "DATE" values.
- Exclude records that fail the defined validation rules.

Data Pipeline

1. Store raw data in "raw_sales_staging".
2. Clean and transform the data.
3. Filter invalid records.
4. Load valid records into "clean_orders".
5. Validate the results using SQL queries.

SQL File

The SQL implementation is available in "sales_data_cleaning.sql".

Validation

The project includes queries to check record counts, missing values, invalid amounts, dates, and order statuses.

Key Skills

- SQL Data Cleaning
- Data Transformation
- Data Type Conversion
- Common Table Expressions
- Data Quality Validation

Notes

This project is designed for MySQL 8.0+. The script should be tested against the source dataset before its results are considered final.
