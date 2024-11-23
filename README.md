# **HR Employee Attrition Analysis - Project**  

## **Overview**  
This project delves into employee attrition data to uncover trends and critical drivers using SQL and Power BI. By analyzing the underlying factors contributing to employee turnover, the project provides actionable insights that empower organizations to adopt data-driven strategies for improving retention and satisfaction.  

## **Features**  
- **SQL-Based Data Analysis:** Advanced querying to extract meaningful insights.  
- **Interactive Power BI Dashboard:** Comprehensive visualizations for decision-makers.  
- **Actionable Recommendations:** Practical strategies to reduce attrition and improve employee experience.

---

## **Table of Contents**  
1. [Dataset Overview](#dataset-overview)  
2. [Objectives](#objectives)  
3. [SQL Query and Analysis](#sql-query-and-analysis)  
4. [Visualizations](#visualizations)  
5. [Tools Used](#tools-used)  
6. [Key Insights](#key-insights)  
7. [Recommendations](#recommendations)  
8. [How to Use](#how-to-use)  
9. [Project Files](#project-files)
10. [Conclusion](#Conclusion)  
11. [Contact](#contact)  

---

## **Dataset Overview**  
- **Size:** 1,470 employee records.  
- **Features:**  
  - **Demographics:** Age, gender, marital status.  
  - **Work Details:** Job role, monthly income, job satisfaction.  
  - **Attrition Factors:** Overtime, distance from home, work-life balance, environment satisfaction, and retrenchment status.  

---

## **Objectives**  
- Identify key factors driving employee attrition.  
- Segment employee groups by their likelihood to leave based on demographic and organizational data.  
- Provide actionable insights to reduce turnover.  
- Create visualizations for stakeholders to monitor and address retention challenges.

---

## **SQL Query and Analysis**  
### 1. **Data Cleaning**  
```sql
-- Remove null values and standardize column names
-- Inspect the first few rows to understand the structure
SELECT TOP 10 * FROM [HR-Employee-Attrition];

-- Check for null values in each column to identify missing data
SELECT 
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS MissingAge,
    SUM(CASE WHEN Department IS NULL THEN 1 ELSE 0 END) AS MissingDepartment
    -- Repeat for each column as necessary
    -- Add other columns similarly
FROM 
    [HR-Employee-Attrition];

-- Add a unique EmployeeID column to the staging table i.e source table
ALTER TABLE [HR-Employee-Attrition]
ADD Employee_ID INT IDENTITY(1,1) PRIMARY KEY;

-- Check for duplicate rows
SELECT 
    Employee_ID, 
    COUNT(*) AS DuplicateCount
FROM 
    [HR-Employee-Attrition]
GROUP BY 
    Employee_ID
HAVING 
    COUNT(*) > 1;
```

### 2. **Attrition by Job Role**  
```sql
-- Calculate attrition counts and rates by job role
SELECT JobRoleName,
       COUNT(*) AS TotalEmployees, 
       SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS EmployeesLeft,
       ROUND(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS AttritionRate
FROM FactEmployeeAttrition f
JOIN DimJobRole j ON f.JobRoleID= j.JobRoleID
GROUP BY JobRoleName;
```

### 3. **Work-Life Balance vs. Attrition**  
```sql
--Work-Life Balance vs. Attrition(This query helps identify if a poor work-life balance is correlated with higher attrition rates).
SELECT 
    WorkLifeBalance,
    COUNT(EmployeeID) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(CAST(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(EmployeeID) * 100, 2) AS AttritionRate
FROM 
    FactEmployeeAttrition
GROUP BY 
    WorkLifeBalance
ORDER BY 
    AttritionRate DESC;
```

### 4. **Attrition by Marital Status**  
```sql
-- Compare attrition rates among different marital statuses
SELECT MaritalStatusName, 
       COUNT(*) AS TotalEmployees, 
       SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS EmployeesLeft,
       ROUND(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS AttritionRate
FROM FactEmployeeAttrition f
JOIN DimMaritalStatus m ON m.MaritalStatusID= f.MaritalStatusID
GROUP BY MaritalStatusName
ORDER BY AttritionRate DESC;
```

### 5. **Attrition by Enviroment Satisfaction**
```sql
--how does the work enviroment influence attrition rate.
SELECT 
    EnvironmentSatisfaction,
    COUNT(CASE WHEN Attrition = 1 THEN 1 END) AS AttritionCount,
    COUNT(EmployeeID) AS TotalEmployees,
    COUNT(CASE WHEN Attrition = 1 THEN 1 END) * 100.0 / COUNT(EmployeeID) AS AttritionRate
FROM 
    FactEmployeeAttrition
GROUP BY 
    EnvironmentSatisfaction
ORDER BY 
    EnvironmentSatisfaction DESC;
```

---

## **Visualizations**  
### **Dashboard Highlights**  
1. **Attrition Rate by Job Role**  
   - *Visualization:* Clustered Bar Chart  
   - *Insight:* Sales Executives and Lab Technicians have the highest attrition rates.  

2. **Work-Life Balance vs. Attrition**  
   - *Visualization:* Stacked Bar Chart  
   - *Insight:* Employees rating work-life balance as 1 or 2 are more likely to leave.  

3. **Attrition by Marital Status**  
   - *Visualization:* Donut Chart  
   - *Insight:* Single employees have a higher likelihood of attrition.  

4. **Attrition vs. Monthly Income**  
   - *Visualization:* Line Chart  
   - *Insight:* Attrition significantly decreases beyond a monthly income threshold of $3,000.  

---

## **Tools Used**  
- **SQL Server:** Data querying and transformation.  
- **Power BI:** Interactive dashboards and advanced DAX calculations.  

---

## **Key Insights**  
- Low Income Drives Attrition: Employees earning <$3,000/month have a 50% higher attrition rate.
- Attrition Rate: High attrition rate observed in specific departments such as Sales and Human Resources.
- Work-Life Balance is Crucial: Employees with ratings of 1 or 2 (Poor and V.Poor) show a 40% higher attrition rate.
- Younger employees (Age 20-30) and single employees show higher attrition rates.
- Job Role Variations: Sales Executives and Lab Technicians have the highest attrition.
- Marital Status Influence: Single employees are more likely to leave compared to married ones.
- Proximity Matters: Employees commuting long distances (>20 km) are more likely to leave.
- Employees with job satisfaction rated 1 (Very Disatisfied) have a 35% higher chance of leaving.
- High-performing employees tend to stay longer when they perceive opportunities for career growth.
- Employees working overtime are more likely to leave, especially if paired with poor work-life balance (rated 1 or 2).
Retrenchment disproportionately impacts employees with poor work-life balance.


---

## **Recommendations**  
1. **Salary Adjustments:** Improve salaries for employees earning less than $3,000/month.  
2. **Support Work-Life Balance:** Introduce flexible hours and remote work options.  
3. **Targeted Retention Efforts:** Focus on single employees through engagement programs such as surveys, team-building activities, and leadership feedback. 
4. **Commute Incentives:** Provide transportation assistance or offer relocation benefits.
5. Retention Programs: Design and implement data-driven retention programs to target high-risk employee groups.
6. Create mentorship and upskilling programs to engage younger employees.
7. Provide additional support to employees undergoing life transitions, such as divorce. 


---

## **How to Use**  
1. **Clone the Repository:**  
   ```bash
   git clone https://github.com/Tibson-Spec/HR_Employee_Attrition_Analysis.git
   ```  
2. **Set Up Database:**  
   - Import the dataset into your SQL Server instance.  
   - Run the SQL scripts for cleaning and analysis.  

3. **Open Dashboard:**  
   - Use Power BI Desktop to explore and interact with the `HR_Attrition_Dashboard.pbix` file.  

4. **Explore Visuals:**  
   - Review insights such as attrition rates by job role, income, and demographics.  

---

## **Project Files**  
- **SQL Scripts:[Click Here](https://github.com/Tibson-spec/HR_Employee_Attrition_Analysis Project/raw/refs/heads/main/HR%20Attrition%20Projects.sql)  
  - `Data_Cleaning.sql`  
  - `Attrition_Analysis.sql`  
- **Power BI Dashboard:**  
  - `HR_Attrition_Dashboard.pbix`  
- **Visuals:**  
  - Dashboard screenshots.  

---

Conclusion
The HR Employee Attrition Analysis project provides valuable insights into the factors influencing employee turnover, enabling organizations to make data-driven decisions to enhance employee retention and satisfaction.

---

## **Contact**  
**Name:** Adedotun Toheeb  
- **LinkedIn:** [Click Here](https://www.linkedin.com/in/adedotun-toheeb-8198021a1)  
- **Email:** Tibson08@gmail.com  

--- 

