-- ============================================================
-- Project: World Layoffs Data Cleaning
-- Dataset: World Layoffs
-- Tool: MySQL Workbench
--
-- Objective:
-- Clean raw layoffs data by removing duplicates,
-- standardizing text, converting dates, handling missing
-- values, and removing records with insufficient layoff data.
-- ============================================================

USE world_layoffs;


-- ============================================================
-- STEP 1: CREATE STAGING TABLE
-- ============================================================

-- Create a staging table with the same structure as the source.
-- This preserves the original raw data.

DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- ============================================================
-- STEP 2: CREATE CLEANING TABLE WITH ROW NUMBERS
-- ============================================================

DROP TABLE IF EXISTS layoffs_clean;

CREATE TABLE layoffs_clean AS
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER (
        PARTITION BY
            company,
            location,
            industry,
            total_laid_off,
            percentage_laid_off,
            `date`,
            stage,
            country,
            funds_raised_millions
        ORDER BY company
    ) AS row_num
FROM layoffs_staging;


-- ============================================================
-- STEP 3: REMOVE DUPLICATE RECORDS
-- ============================================================

DELETE FROM layoffs_clean
WHERE row_num > 1;


-- ============================================================
-- STEP 4: STANDARDIZE TEXT VALUES
-- ============================================================

-- Remove leading and trailing spaces from company names.

UPDATE layoffs_clean
SET company = TRIM(company);


-- Convert blank industry values into NULL.

UPDATE layoffs_clean
SET industry = NULL
WHERE industry IS NOT NULL
  AND TRIM(industry) = '';


-- Standardize cryptocurrency industry names.

UPDATE layoffs_clean
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- Remove trailing periods from country names.

UPDATE layoffs_clean
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- ============================================================
-- STEP 5: STANDARDIZE DATE VALUES
-- ============================================================

-- Convert text dates into DATE values.
-- Invalid date strings may become NULL, depending on SQL mode.

UPDATE layoffs_clean
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

ALTER TABLE layoffs_clean
MODIFY COLUMN `date` DATE;


-- ============================================================
-- STEP 6: HANDLE MISSING INDUSTRY VALUES
-- ============================================================

-- Populate missing industries when another record for the
-- same company and location has a known industry.

UPDATE layoffs_clean AS t1
JOIN layoffs_clean AS t2
    ON t1.company = t2.company
   AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- ============================================================
-- STEP 7: REMOVE RECORDS WITH NO LAYOFF INFORMATION
-- ============================================================

-- Remove records when both layoff count and layoff percentage
-- are missing.

DELETE FROM layoffs_clean
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ============================================================
-- STEP 8: REMOVE TEMPORARY ROW NUMBER COLUMN
-- ============================================================

ALTER TABLE layoffs_clean
DROP COLUMN row_num;


-- ============================================================
-- STEP 9: VALIDATE CLEANED DATA
-- ============================================================

-- Check the total number of remaining records.

SELECT COUNT(*) AS total_records
FROM layoffs_clean;


-- Check for remaining duplicate groups.

SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM layoffs_clean
GROUP BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
HAVING COUNT(*) > 1;


-- Check for missing values in important columns.

SELECT
    SUM(company IS NULL OR TRIM(company) = '') AS missing_company,
    SUM(`date` IS NULL) AS missing_date,
    SUM(total_laid_off IS NULL) AS missing_layoff_count,
    SUM(percentage_laid_off IS NULL) AS missing_layoff_percentage,
    SUM(industry IS NULL) AS missing_industry
FROM layoffs_clean;


-- Preview the final cleaned dataset.

SELECT *
FROM layoffs_clean;
