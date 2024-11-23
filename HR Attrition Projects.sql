--HR Attrition Data Cleaning and Normalization

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

-- Remove duplicate records based on EmployeeNumber
WITH CTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY  Employee_ID ORDER BY  Employee_ID) AS RowNum
    FROM [HR-Employee-Attrition]
        
)
DELETE FROM CTE WHERE RowNum > 1;


--HR Attrition Exploratory Analysis
--Creating Tables

-- Creating DimDepartment table
CREATE TABLE DimDepartment (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(50) UNIQUE
);

-- Creating DimJobRole table
CREATE TABLE DimJobRole (
    JobRoleID INT IDENTITY(1,1) PRIMARY KEY,
    JobRoleName VARCHAR(50) UNIQUE
);

-- Creating DimEducationField table
CREATE TABLE DimEducationField (
    EducationFieldID INT IDENTITY(1,1) PRIMARY KEY,
    EducationFieldName VARCHAR(50) UNIQUE
);

-- Creating DimGender table
CREATE TABLE DimGender (
    GenderID INT IDENTITY(1,1) PRIMARY KEY,
    GenderName VARCHAR(10) UNIQUE
);

-- Creating Marital status Dimension table
CREATE TABLE DimMaritalStatus (
    MaritalStatusID INT IDENTITY(1,1) PRIMARY KEY,
    MaritalStatusName VARCHAR(20) UNIQUE
);

--Creating Business travel dimension table
CREATE TABLE DimBusinessTravel (
     BusinessTravelID INT IDENTITY(1,1) PRIMARY KEY,
	 BusinessTravelName VARCHAR(20) UNIQUE
);


--Populating dimension table
-- Populate Department table
INSERT INTO DimDepartment (DepartmentName)
SELECT DISTINCT Department
FROM [HR-Employee-Attrition];

-- Populate Job Role dimension table
INSERT INTO DimJobRole (JobRoleName)
SELECT DISTINCT JobRole
FROM [HR-Employee-Attrition];

-- Populate Education Field dimension table
INSERT INTO DimEducationField (EducationFieldName)
SELECT DISTINCT EducationField
FROM [HR-Employee-Attrition];

-- Populate Gender dimension table
INSERT INTO DimGender (GenderName)
SELECT DISTINCT Gender
FROM [HR-Employee-Attrition];

-- Populate Marital Status dimension table
INSERT INTO DimMaritalStatus (MaritalStatusName)
SELECT DISTINCT MaritalStatus
FROM [HR-Employee-Attrition];

-- Populate Business travel dimension table
INSERT INTO DimBusinessTravel(BusinessTravelName)
SELECT DISTINCT BusinessTravel
FROM [HR-Employee-Attrition];

--Creating Employee fact table
CREATE TABLE FactEmployeeAttrition (
    EmployeeID INT PRIMARY KEY, -- Unique identifier from the staging table
    Age INT,
    MonthlyIncome DECIMAL(10, 2),
	MonthlyRate DECIMAL(10, 2),
    DistanceFromHome INT,
    JobSatisfaction INT,
    PerformanceRating INT,
    EnvironmentSatisfaction INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
	TotalWorkingYears INT,
	NumCompaniesWorked INT,
    YearsInCurrentRole INT,
    YearsWithCurrManager INT,
	HourlyRate INT,
	JobLevel INT,
	Overtime INT,
	PercentSalaryHike INT,
    Attrition VARCHAR(10),

 -- Foreign keys linking to dimensions
    DepartmentID INT FOREIGN KEY REFERENCES DimDepartment(DepartmentID),
    JobRoleID INT FOREIGN KEY REFERENCES DimJobRole(JobRoleID),
    EducationFieldID INT FOREIGN KEY REFERENCES DimEducationField(EducationFieldID),
    GenderID INT FOREIGN KEY REFERENCES DimGender(GenderID),
    MaritalStatusID INT FOREIGN KEY REFERENCES DimMaritalStatus(MaritalStatusID),
	BusinessTravelID INT FOREIGN KEY REFERENCES DimBusinessTravel(BusinessTravelID)
);

--In order to create successful fact table, added foreign key columns to [HR-Employee-Attrition]
ALTER TABLE [HR-Employee-Attrition]
ADD DepartmentID INT,
    JobRoleID INT,
    EducationFieldID INT,
    GenderID INT,
    MaritalStatusID INT,
	BusinessTravelID INT;

--Populate Foreign key column in HR-Employee-Attrition table
-- Populate DepartmentID
UPDATE [HR-Employee-Attrition]
SET DepartmentID = d.DepartmentID
FROM [HR-Employee-Attrition] f
JOIN DimDepartment d ON f.Department = d.DepartmentName;

-- Populate JobRoleID
UPDATE [HR-Employee-Attrition]
SET JobRoleID = j.JobRoleID
FROM [HR-Employee-Attrition] f
JOIN DimJobRole j ON f.JobRole = j.JobRoleName;

-- Populate EducationFieldID
UPDATE [HR-Employee-Attrition]
SET EducationFieldID = e.EducationFieldID
FROM [HR-Employee-Attrition] f
JOIN DimEducationField e ON f.EducationField = e.EducationFieldName;

-- Populate GenderID
UPDATE [HR-Employee-Attrition]
SET GenderID = g.GenderID
FROM [HR-Employee-Attrition] f
JOIN DimGender g ON f.Gender = g.GenderName;

-- Populate MaritalStatusID
UPDATE [HR-Employee-Attrition]
SET MaritalStatusID = m.MaritalStatusID
FROM [HR-Employee-Attrition] f
JOIN DimMaritalStatus m ON f.MaritalStatus = m.MaritalStatusName;

-- Populate BusinessTravelID
UPDATE [HR-Employee-Attrition]
SET BusinessTravelID = b.BusinessTravelID
FROM [HR-Employee-Attrition] f
JOIN DimBusinessTravel b ON f.BusinessTravel = b.BusinessTravelName;

--Populate the Fact Table Using Foreign Key IDs
--Now that the hr attrition contains the foreign keys as IDs, insert data into the fact table by referencing these ID columns instead of the names.
INSERT INTO FactEmployeeAttrition (
    EmployeeID, Age, MonthlyIncome, MonthlyRate, DistanceFromHome, JobSatisfaction, PerformanceRating,EnvironmentSatisfaction,
	WorkLifeBalance,YearsAtCompany,TotalWorkingYears,NumCompaniesWorked,YearsInCurrentRole,YearsWithCurrManager,HourlyRate,JobLevel,
	Overtime,PercentSalaryHike,Attrition, DepartmentID, JobRoleID, EducationFieldID, GenderID, MaritalStatusID, BusinessTravelID
)
SELECT 
    f.Employee_ID,
    f.Age,
    f.MonthlyIncome,
	f.MonthlyRate,
    f. DistanceFromHome,
    f.JobSatisfaction,
    f.PerformanceRating,
    f.EnvironmentSatisfaction,
    f.WorkLifeBalance,
    f.YearsAtCompany,
	f.TotalWorkingYears,
	f.NumCompaniesWorked,
    f.YearsInCurrentRole,
    f.YearsWithCurrManager,
	f.HourlyRate,
	f.JobLevel,
	f.Overtime,
	f.PercentSalaryHike,
    f.Attrition,
    d.DepartmentID,
    j.JobRoleID,
    e.EducationFieldID,
    g.GenderID,
    m.MaritalStatusID,
	b.BusinessTravelID
FROM 
    [HR-Employee-Attrition] f;


--Analysis Queries
--Calculate the attrition rate across different departments.
SELECT 
    d.DepartmentName,
	COUNT(f.EmployeeID) AS TotalEmployees,
	COUNT(CASE WHEN Attrition = 1 THEN 1 END) AS AttritionCount,
    ROUND(COUNT(CASE WHEN f.Attrition = 1 THEN 1 END) * 100.0 / COUNT(f.EmployeeID),2) AS AttritionRate
FROM 
    FactEmployeeAttrition f
JOIN 
    DimDepartment d ON f.DepartmentID = d.DepartmentID
GROUP BY 
    d.DepartmentName
ORDER BY AttritionRate DESC;

--Average monthly income by job role
SELECT 
    j.JobRoleName,
    ROUND(AVG(f.MonthlyIncome),2) AS AvgMonthlyIncome
FROM 
    FactEmployeeAttrition f
JOIN 
    DimJobRole j ON f.JobRoleID = j.JobRoleID
GROUP BY 
    j.JobRoleName
ORDER BY AvgMonthlyIncome DESC;

--Attrition Rate by Age Group
SELECT 
    CASE 
        WHEN Age < 30 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+' 
    END AS AgeGroup,
    COUNT(EmployeeID) AS TotalEmployees,
    ROUND(COUNT(CASE WHEN f.Attrition = 1 THEN 1 END) * 100.0 / COUNT(f.EmployeeID),2) AS AttritionRate
FROM 
    FactEmployeeAttrition f
GROUP BY 
    CASE 
        WHEN Age < 30 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+' 
    END
ORDER BY 
    AttritionRate DESC;

--Evaluate the job satisfaction level and its impact on attrition.
SELECT 
    JobSatisfaction,
    COUNT(CASE WHEN Attrition = 1 THEN 1 END) AS AttritionCount,
    COUNT(EmployeeID) AS TotalEmployees,
    COUNT(CASE WHEN Attrition = 1 THEN 1 END) * 100.0 / COUNT(EmployeeID) AS AttritionRate
FROM 
    FactEmployeeAttrition
GROUP BY 
    JobSatisfaction
ORDER BY 
    JobSatisfaction DESC;

--Average Years at Company by Marital Status (Analyze the tenure based on marital status).
SELECT 
    m.MaritalStatusName,
    AVG(f.YearsAtCompany) AS AvgYearsAtCompany
FROM 
    FactEmployeeAttrition f
JOIN 
    DimMaritalStatus m ON f.MaritalStatusID = m.MaritalStatusID
GROUP BY 
    m.MaritalStatusName 
ORDER BY AvgYearsAtCompany DESC;

--Average Tenure of Employees by Department(Examining the average number of years employees stay in each department).
SELECT 
    d.DepartmentName AS Department,
    AVG(f.YearsAtCompany) AS AvgYearsAtCompany
FROM 
    FactEmployeeAttrition f
JOIN 
    DimDepartment d ON f.DepartmentID = d.DepartmentID
GROUP BY 
    d.DepartmentName
ORDER BY 
    AvgYearsAtCompany DESC;

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

--Education Level and Monthly Income Analysis (This query examines how monthly income varies with education level).
SELECT    
	e.EducationFieldName AS EducationField,
    ROUND(AVG(f.MonthlyIncome),2) AS AvgMonthlyIncome
FROM 
    FactEmployeeAttrition f
JOIN 
    DimEducationField e ON f.EducationFieldID = e.EducationFieldID
GROUP BY 
    e.EducationFieldName
ORDER BY 
    AvgMonthlyIncome DESC;

--Gender Distribution of Attrition
SELECT 
    g.GenderName AS Gender,
    COUNT(f.EmployeeID) AS TotalEmployees,
    SUM(CASE WHEN f.Attrition = 1 THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(CAST(SUM(CASE WHEN f.Attrition = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(f.EmployeeID) * 100, 2) AS AttritionRate
FROM 
    FactEmployeeAttrition f
JOIN 
    DimGender g ON f.GenderID = g.GenderID
GROUP BY 
    g.GenderName
ORDER BY 
    AttritionRate DESC;

--Monthly Income Distribution by Marital Status (I.E Analyzing income by marital)
SELECT 
    m.MaritalStatusName AS MaritalStatus,
    ROUND(CAST(AVG(f.MonthlyIncome) AS FLOAT),2) AS AvgMonthlyIncome
FROM 
    FactEmployeeAttrition f
JOIN 
    DimMaritalStatus m ON f.MaritalStatusID = m.MaritalStatusID
GROUP BY 
    m.MaritalStatusName
ORDER BY 
    AvgMonthlyIncome DESC;

--Years with Current Manager and Attrition Correlation
SELECT 
    YearsWithCurrManager,
    COUNT(EmployeeID) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(CAST(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(EmployeeID) * 100, 2) AS AttritionRate
FROM 
    FactEmployeeAttrition
GROUP BY 
    YearsWithCurrManager
ORDER BY 
    AttritionRate DESC;

