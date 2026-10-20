# 📉 Layoffs Data Cleaning Project (MySQL)

This project demonstrates a complete, end-to-end **Data Cleaning and Preparation Pipeline** using **MySQL Workbench**. The objective is to take a raw dataset containing global tech and industry layoffs, inspect data anomalies, build a secure staging environment, and transform dirty data into a clean, analysis-ready format suitable for advanced Business Intelligence (BI) tools like Excel and Power BI.

---

## 🛠️ Project Workflow & Steps

The data cleaning process was executed systematically through the following phases:

### 1. Creating a Staging Table (`Staging Environment`)
* **Why?** Never modify the raw dataset directly. A staging table (`layoffs_staging`) was created as an exact copy of the raw data to ensure raw data integrity remains intact throughout the cleaning process.

### 2. Removing Duplicates (`Deduplication`)
* **Methodology:** Since the raw dataset lacked a unique primary key (`id`), a Common Table Expression (CTE) combined with the window function `ROW_NUMBER()` was utilized.
* **Partitioning:** Partitioned the data across all columns (`company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`) to accurately pinpoint exact duplicate rows.
* **Execution:** Filtered for `row_num > 1` to identify and safely delete redundant entries.

### 3. Standardizing Data (`Data Normalization`)
* **Text Cleanup:** Used `TRIM()` to remove unwanted leading and trailing whitespace from company names and text fields.
* **Category Correction:** Fixed spelling and naming inconsistencies in the `industry` column (e.g., standardizing multiple variations of crypto-related categories into a single uniform name).
* **Country Cleanup:** Inspected and corrected trailing punctuation/characters (e.g., fixing variations like `'United States.'` to `'United States'`).
* **Date Transformation:** Converted the `date` column from text (`VARCHAR`) format into a proper SQL `DATE` data type using `STR_TO_DATE()` and updated the column definition using `MODIFY COLUMN` to enable time-series analytics.

### 4. Handling Null & Blank Values (`Missing Data Imputation`)
* **Blank to Null:** Converted empty string values (`''`) in text columns into proper `NULL` values to ensure accurate conditional filtering.
* **Self-Join Imputation:** Wrote a smart SQL `JOIN` query to populate missing `industry` fields. If a company had multiple rows where one row had an industry specified and another had a `NULL` industry, the missing value was dynamically filled using the existing valid data for that company.

### 5. Removing Irrelevant Data (`Data Filtering`)
* **Useless Rows:** Deleted rows where both `total_laid_off` and `percentage_laid_off` were `NULL`, as they provided zero analytical value for layoff trends.
* **Cleanup:** Dropped auxiliary columns (such as the temporary `row_num` tracking column) used strictly during the deduplication phase.

---

## 💻 Technologies & SQL Concepts Used
* **Database Management System:** MySQL Workbench
* **Key SQL Techniques:**
  * CTEs (Common Table Expressions)
  * Window Functions (`ROW_NUMBER()`)
  * String Manipulation (`TRIM`, `SUBSTRING`, `REPLACE`)
  * Date Functions (`STR_TO_DATE`, `DATE_FORMAT`)
  * Data Type Alterations (`MODIFY COLUMN`)
  * Self-Joins for Data Imputation
  * Aggregate Functions & Grouping (`GROUP BY`, `HAVING`)

---

## 🚀 Next Steps & Integration
Following the completion of this robust SQL data cleaning pipeline, the cleaned dataset was exported to **Microsoft Excel** to build interactive Pivot Tables, Pivot Charts, and a comprehensive multi-chart analytics dashboard tracking layoffs by company, industry, country, and funding stage.
