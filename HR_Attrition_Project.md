# 📊 HR Employee Attrition & Data Cleaning Project

**Author:** Majd Adwan  
**Tool / Tech Stack:** MySQL Workbench / SQL  

---

## 📌 1. Project Overview
This project demonstrates end-to-end data cleaning and analytical querying skills using SQL on a Human Resources (HR) dataset. The primary business objective is to analyze employee turnover and answer critical workforce questions:
* Which departments suffer from the highest employee attrition rates?
* Is there a correlation between average salary levels and employee turnover?

---

## 📁 Repository Structure
```text
├── sql_scripts/
│   ├── 01_schema_and_raw_data.sql
│   ├── 02_data_cleaning.sql
│   └── 03_analytical_queries.sql
└── README.md

🛠️ 2. Database Setup & Raw Data
First, the database and raw landing table are created. Note that salary is created as a VARCHAR to temporarily accept raw text formatting and monetary symbols ($).

CREATE DATABASE IF NOT EXISTS hr_project;
USE hr_project;

CREATE TABLE raw_employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Active'
);

🧹 3. Data Cleaning Pipeline
To fix text inconsistencies, extra whitespace, and incorrect data types, a structured cleaning view (vw_clean_employees) is defined:
Text Standardization: Applied TRIM() and UPPER() to standardize department formatting.
Type Casting & Symbol Removal: Used REPLACE() to strip $ signs and cast the sanitized strings to DECIMAL(10,2).
Missing Value Management: Handled missing/empty salary values using conditional CASE WHEN logic.

CREATE VIEW vw_clean_employees AS
SELECT 
    emp_id,
    emp_name,
    TRIM(UPPER(department)) AS department,
    CASE 
        WHEN salary IS NULL OR salary = '' THEN 0
        ELSE CAST(REPLACE(salary, '$', '') AS DECIMAL(10,2))
    END AS clean_salary,
    status
FROM raw_employees;


📈 4. Main Analytical Query
This analytical query aggregates transformed employee metrics per department to calculate headcount, total resignations, attrition rate percentages, and average salary levels.

SELECT 
    department,
    COUNT(emp_id) AS total_employees,
    SUM(CASE WHEN status = 'Left' THEN 1 ELSE 0 END) AS left_employees,
    ROUND((SUM(CASE WHEN status = 'Left' THEN 1 ELSE 0 END) / COUNT(emp_id)) * 100, 2) AS attrition_rate_pct,
    ROUND(AVG(clean_salary), 2) AS average_salary
FROM vw_clean_employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;


💡 5. Key Business Insights &
Recommendations
⚠️ High Turnover in Sales: The Sales department exhibits the highest employee attrition rate across the organization.
💰 Salary Gap Impact: Employees in Sales receive the lowest average salary compared to other operational departments (such as IT and HR), pointing to financial compensation as a primary driver for turnover.
🎯 Actionable Recommendations:
Re-evaluate the base compensation structure and incentive packages for the Sales team.
Conduct stay interviews and workplace satisfaction surveys to mitigate retention risks.
