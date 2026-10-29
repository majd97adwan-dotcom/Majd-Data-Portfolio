-- ============================================================
-- Project: HR Employee Attrition Analysis
-- Tool: MySQL 8.0+
-- Fix: missing salaries are kept as NULL (not 0) so they do not
--      drag down the average salary per department.
-- ============================================================

CREATE DATABASE IF NOT EXISTS hr_project;
USE hr_project;

-- 1. RAW TABLE (salary is VARCHAR because raw data contains '$' and blanks)
DROP TABLE IF EXISTS raw_employees;
CREATE TABLE raw_employees (
    emp_id     INT AUTO_INCREMENT PRIMARY KEY,
    emp_name   VARCHAR(50),
    department VARCHAR(50),
    salary     VARCHAR(50),
    status     VARCHAR(20) DEFAULT 'Active'
);

-- Sample data so the script can be run end-to-end (replace with your real data)
INSERT INTO raw_employees (emp_name, department, salary, status) VALUES
('Ali',   ' sales ', '$2,000', 'Left'),
('Sara',  'Sales',    '',       'Left'),
('Omar',  'SALES',    '$2,200', 'Active'),
('Lina',  'it',       '$4,500', 'Active'),
('Hadi',  'IT ',      '$4,800', 'Left'),
('Rana',  'HR',       '$3,500', 'Active'),
('Zaid',  'HR',       NULL,     'Active'),
('Maya',  'hr',       '$3,700', 'Left');

-- 2. CLEANING VIEW
CREATE OR REPLACE VIEW vw_clean_employees AS
SELECT
    emp_id,
    emp_name,
    UPPER(TRIM(department)) AS department,
    -- Missing salary stays NULL: AVG() ignores NULL, a fake 0 would not
    CASE
        WHEN salary IS NULL OR TRIM(salary) = '' THEN NULL
        ELSE CAST(REPLACE(REPLACE(TRIM(salary), '$', ''), ',', '') AS DECIMAL(10,2))
    END AS clean_salary,
    -- Normalize status so 'left', 'LEFT ' etc. are all counted
    CASE
        WHEN UPPER(TRIM(status)) = 'LEFT' THEN 'Left'
        ELSE 'Active'
    END AS status
FROM raw_employees;

-- 3. MAIN ANALYSIS: attrition per department
SELECT
    department,
    COUNT(*)                                             AS total_employees,
    SUM(status = 'Left')                                 AS left_employees,
    ROUND(SUM(status = 'Left') / COUNT(*) * 100, 2)      AS attrition_rate_pct,
    ROUND(AVG(clean_salary), 2)                          AS avg_salary,
    COUNT(clean_salary)                                  AS salaries_known,
    COUNT(*) - COUNT(clean_salary)                       AS salaries_missing
FROM vw_clean_employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;

-- 4. DOES SALARY RELATE TO LEAVING? (compare leavers vs stayers)
SELECT
    status,
    COUNT(*)                        AS employees,
    ROUND(AVG(clean_salary), 2)     AS avg_salary
FROM vw_clean_employees
WHERE clean_salary IS NOT NULL
GROUP BY status;
