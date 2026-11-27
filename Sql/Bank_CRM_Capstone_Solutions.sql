USE bank_crm;

SELECT
    g.GeographyLocation AS Region,
    COUNT(b.CustomerId) AS Total_Customers,
    ROUND(AVG(b.Balance), 2) AS Average_Balance,
    ROUND(SUM(b.Balance), 2) AS Total_Balance
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
JOIN Geography g
    ON c.GeographyID = g.GeographyID
GROUP BY g.GeographyLocation
ORDER BY Total_Balance DESC;

USE bank_crm;

WITH latest_year AS (
    SELECT MAX(YEAR(Bank_DOJ_Date)) AS max_year
    FROM CustomerInfo
)
SELECT
    c.CustomerId,
    c.Surname,
    c.EstimatedSalary,
    c.Bank_DOJ_Date
FROM CustomerInfo c
CROSS JOIN latest_year y
WHERE YEAR(c.Bank_DOJ_Date) = y.max_year
  AND QUARTER(c.Bank_DOJ_Date) = 4
ORDER BY c.EstimatedSalary DESC
LIMIT 5;

USE bank_crm;

SELECT
    ROUND(AVG(NumOfProducts), 2) AS Average_Products
FROM Bank_Churn
WHERE HasCrCard = 1;

USE bank_crm;

WITH latest_year AS (
    SELECT MAX(YEAR(Bank_DOJ_Date)) AS max_year
    FROM CustomerInfo
)
SELECT
    g.GenderCategory AS Gender,
    COUNT(b.CustomerId) AS Total_Customers,
    SUM(b.Exited) AS Exited_Customers,
    ROUND(
        SUM(b.Exited) * 100.0 / COUNT(b.CustomerId), 2
    ) AS Churn_Rate_Percentage
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
JOIN Gender g
    ON c.GenderID = g.GenderID
CROSS JOIN latest_year y
WHERE YEAR(c.Bank_DOJ_Date) = y.max_year
GROUP BY g.GenderCategory
ORDER BY Churn_Rate_Percentage DESC;

SELECT
    e.ExitCategory AS Customer_Status,
    COUNT(b.CustomerId) AS Total_Customers,
    ROUND(AVG(b.CreditScore), 2) AS Average_Credit_Score
FROM Bank_Churn b
JOIN ExitCustomer e
    ON b.Exited = e.ExitID
GROUP BY e.ExitCategory
ORDER BY Average_Credit_Score DESC;

SELECT
    g.GenderCategory AS Gender,
    ROUND(AVG(c.EstimatedSalary), 2) AS Average_Estimated_Salary,
    COUNT(
        CASE WHEN b.IsActiveMember = 1 THEN b.CustomerId END
    ) AS Active_Accounts,
    COUNT(b.CustomerId) AS Total_Customers
FROM CustomerInfo c
JOIN Bank_Churn b
    ON c.CustomerId = b.CustomerId
JOIN Gender g
    ON c.GenderID = g.GenderID
GROUP BY g.GenderCategory
ORDER BY Average_Estimated_Salary DESC;

WITH Credit_Score_Segments AS (
    SELECT
        CustomerId,
        Exited,
        CASE
            WHEN CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
            WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
            WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
            WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
            WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
            ELSE 'Unclassified'
        END AS Credit_Score_Category
    FROM Bank_Churn
)
SELECT
    Credit_Score_Category,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Exited_Customers,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2) AS Exit_Rate_Percentage
FROM Credit_Score_Segments
GROUP BY Credit_Score_Category
ORDER BY Exit_Rate_Percentage DESC;

SELECT
    g.GeographyLocation AS Region,
    COUNT(b.CustomerId) AS Active_Customers
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
JOIN Geography g
    ON c.GeographyID = g.GeographyID
WHERE b.IsActiveMember = 1
  AND b.Tenure > 5
GROUP BY g.GeographyLocation
ORDER BY Active_Customers DESC;

SELECT
    CASE
        WHEN HasCrCard = 1 THEN 'Credit Card Holder'
        WHEN HasCrCard = 0 THEN 'No Credit Card'
    END AS Credit_Card_Status,
    COUNT(CustomerId) AS Total_Customers,
    SUM(Exited) AS Exited_Customers,
    ROUND(
        SUM(Exited) * 100.0 / COUNT(CustomerId), 2
    ) AS Churn_Rate_Percentage
FROM Bank_Churn
GROUP BY HasCrCard
ORDER BY Churn_Rate_Percentage DESC;

SELECT
    NumOfProducts,
    COUNT(CustomerId) AS Total_Customers
FROM Bank_Churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY Total_Customers DESC;

SELECT
    YEAR(Bank_DOJ_Date) AS Joining_Year,
    MONTH(Bank_DOJ_Date) AS Joining_Month,
    MONTHNAME(Bank_DOJ_Date) AS Month_Name,
    COUNT(CustomerId) AS New_Customers
FROM CustomerInfo
GROUP BY
    YEAR(Bank_DOJ_Date),
    MONTH(Bank_DOJ_Date),
    MONTHNAME(Bank_DOJ_Date)
ORDER BY Joining_Year, Joining_Month;

SELECT
    NumOfProducts,
    COUNT(CustomerId) AS Total_Exited_Customers,
    ROUND(AVG(Balance), 2) AS Average_Account_Balance,
    ROUND(MIN(Balance), 2) AS Minimum_Balance,
    ROUND(MAX(Balance), 2) AS Maximum_Balance
FROM Bank_Churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

WITH Ranked_Balances AS (
    SELECT
        CustomerId,
        Balance,
        NTILE(4) OVER (ORDER BY Balance) AS Quartile
    FROM Bank_Churn
    WHERE Exited = 0
),
Quartiles AS (
    SELECT
        MAX(CASE WHEN Quartile = 1 THEN Balance END) AS Q1,
        MIN(CASE WHEN Quartile = 4 THEN Balance END) AS Q3
    FROM Ranked_Balances
),
Bounds AS (
    SELECT
        Q1,
        Q3,
        Q1 - 1.5 * (Q3 - Q1) AS Lower_Bound,
        Q3 + 1.5 * (Q3 - Q1) AS Upper_Bound
    FROM Quartiles
)
SELECT
    COUNT(r.CustomerId) AS Total_Potential_Outliers,
    ROUND(b.Lower_Bound, 2) AS Lower_Bound,
    ROUND(b.Upper_Bound, 2) AS Upper_Bound
FROM Bounds b
LEFT JOIN Ranked_Balances r
    ON r.Balance < b.Lower_Bound
    OR r.Balance > b.Upper_Bound
GROUP BY b.Lower_Bound, b.Upper_Bound;

SELECT
    'Bank_Churn' AS Table_Name,
    COUNT(*) AS Total_Records
FROM Bank_Churn

UNION ALL

SELECT 'CustomerInfo', COUNT(*) FROM CustomerInfo
UNION ALL
SELECT 'ActiveCustomer', COUNT(*) FROM ActiveCustomer
UNION ALL
SELECT 'CreditCard', COUNT(*) FROM CreditCard
UNION ALL
SELECT 'ExitCustomer', COUNT(*) FROM ExitCustomer
UNION ALL
SELECT 'Gender', COUNT(*) FROM Gender
UNION ALL
SELECT 'Geography', COUNT(*) FROM Geography;

WITH Gender_Income AS (
    SELECT
        c.GeographyID,
        g.GenderCategory AS Gender,
        ROUND(AVG(c.EstimatedSalary), 2) AS Average_Income
    FROM CustomerInfo c
    JOIN Gender g
        ON c.GenderID = g.GenderID
    GROUP BY
        c.GeographyID,
        g.GenderCategory
)
SELECT
    GeographyID,
    Gender,
    Average_Income,
    RANK() OVER (
        PARTITION BY GeographyID
        ORDER BY Average_Income DESC
    ) AS Income_Rank
FROM Gender_Income
ORDER BY GeographyID, Income_Rank;

SELECT
    CASE
        WHEN c.Age BETWEEN 18 AND 29 THEN '18-29'
        WHEN c.Age BETWEEN 30 AND 49 THEN '30-49'
        WHEN c.Age >= 50 THEN '50+'
    END AS Age_Bracket,
    COUNT(b.CustomerId) AS Exited_Customers,
    ROUND(AVG(b.Tenure), 2) AS Average_Tenure
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
WHERE b.Exited = 1
GROUP BY Age_Bracket
ORDER BY
    CASE
        WHEN Age_Bracket = '18-29' THEN 1
        WHEN Age_Bracket = '30-49' THEN 2
        WHEN Age_Bracket = '50+' THEN 3
    END;
    
    SELECT
    CASE
        WHEN b.Exited = 1 THEN 'Exited'
        ELSE 'Retained'
    END AS Customer_Status,
    ROUND(
        (
            COUNT(*) * SUM(c.EstimatedSalary * b.Balance)
            - SUM(c.EstimatedSalary) * SUM(b.Balance)
        )
        /
        NULLIF(
            SQRT(
                (
                    COUNT(*) * SUM(c.EstimatedSalary * c.EstimatedSalary)
                    - POW(SUM(c.EstimatedSalary), 2)
                )
                *
                (
                    COUNT(*) * SUM(b.Balance * b.Balance)
                    - POW(SUM(b.Balance), 2)
                )
            ), 0
        ), 4
    ) AS Salary_Balance_Correlation
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
GROUP BY b.Exited;

SELECT
    ROUND(
        (
            COUNT(*) * SUM(c.EstimatedSalary * b.CreditScore)
            - SUM(c.EstimatedSalary) * SUM(b.CreditScore)
        )
        /
        NULLIF(
            SQRT(
                (
                    COUNT(*) * SUM(c.EstimatedSalary * c.EstimatedSalary)
                    - POW(SUM(c.EstimatedSalary), 2)
                )
                *
                (
                    COUNT(*) * SUM(b.CreditScore * b.CreditScore)
                    - POW(SUM(b.CreditScore), 2)
                )
            ), 0
        ), 4
    ) AS Salary_CreditScore_Correlation
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId;
    
    WITH Credit_Score_Buckets AS (
    SELECT
        CustomerId,
        Exited,
        CASE
            WHEN CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
            WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
            WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
            WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
            WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
            ELSE 'Unclassified'
        END AS Credit_Score_Bucket
    FROM Bank_Churn
),
Churn_Counts AS (
    SELECT
        Credit_Score_Bucket,
        COUNT(*) AS Churned_Customers
    FROM Credit_Score_Buckets
    WHERE Exited = 1
    GROUP BY Credit_Score_Bucket
)
SELECT
    Credit_Score_Bucket,
    Churned_Customers,
    RANK() OVER (
        ORDER BY Churned_Customers DESC
    ) AS Churn_Rank
FROM Churn_Counts
ORDER BY Churn_Rank;

WITH Age_Buckets AS (
    SELECT
        b.CustomerId,
        b.HasCrCard,
        CASE
            WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN c.Age BETWEEN 31 AND 40 THEN '31-40'
            WHEN c.Age BETWEEN 41 AND 50 THEN '41-50'
            WHEN c.Age BETWEEN 51 AND 60 THEN '51-60'
            ELSE '61+'
        END AS Age_Bucket
    FROM Bank_Churn b
    JOIN CustomerInfo c
        ON b.CustomerId = c.CustomerId
),
Card_Counts AS (
    SELECT
        Age_Bucket,
        COUNT(*) AS Credit_Card_Customers
    FROM Age_Buckets
    WHERE HasCrCard = 1
    GROUP BY Age_Bucket
)
SELECT
    Age_Bucket,
    Credit_Card_Customers,
    ROUND(AVG(Credit_Card_Customers) OVER (), 2)
        AS Average_Cards_Per_Bucket
FROM Card_Counts
WHERE Credit_Card_Customers < (
    SELECT AVG(Credit_Card_Customers)
    FROM Card_Counts
)
ORDER BY Age_Bucket;

WITH Geography_Analysis AS (
    SELECT
        g.GeographyLocation AS Location,
        COUNT(
            CASE WHEN b.Exited = 1 THEN b.CustomerId END
        ) AS Churned_Customers,
        ROUND(AVG(b.Balance), 2) AS Average_Balance
    FROM Bank_Churn b
    JOIN CustomerInfo c
        ON b.CustomerId = c.CustomerId
    JOIN Geography g
        ON c.GeographyID = g.GeographyID
    GROUP BY g.GeographyLocation
)
SELECT
    Location,
    Churned_Customers,
    Average_Balance,
    RANK() OVER (
        ORDER BY Churned_Customers DESC
    ) AS Churn_Rank,
    RANK() OVER (
        ORDER BY Average_Balance DESC
    ) AS Balance_Rank
FROM Geography_Analysis
ORDER BY Churn_Rank;

SELECT
    CustomerId,
    Surname,
    CONCAT(CustomerId, '_', Surname) AS CustomerID_Surname
FROM CustomerInfo;

SELECT
    b.CustomerId,
    b.Exited,
    (
        SELECT e.ExitCategory
        FROM ExitCustomer e
        WHERE e.ExitID = b.Exited
    ) AS ExitCategory
FROM Bank_Churn b;

SELECT
    'Bank_Churn' AS Table_Name,
    SUM(CustomerId IS NULL) AS Missing_CustomerId,
    SUM(CreditScore IS NULL) AS Missing_CreditScore,
    SUM(Tenure IS NULL) AS Missing_Tenure,
    SUM(Balance IS NULL) AS Missing_Balance,
    SUM(NumOfProducts IS NULL) AS Missing_NumOfProducts,
    SUM(HasCrCard IS NULL) AS Missing_HasCrCard,
    SUM(IsActiveMember IS NULL) AS Missing_IsActiveMember,
    SUM(Exited IS NULL) AS Missing_Exited
FROM Bank_Churn;

SELECT
    c.CustomerId,
    c.Surname,
    CASE
        WHEN b.IsActiveMember = 1 THEN 'Active'
        WHEN b.IsActiveMember = 0 THEN 'Inactive'
    END AS Activity_Status
FROM CustomerInfo c
JOIN Bank_Churn b
    ON c.CustomerId = b.CustomerId
WHERE c.Surname LIKE '%on'
ORDER BY c.CustomerId;

SELECT
    IsActiveMember,
    Exited,
    COUNT(CustomerId) AS Total_Customers
FROM Bank_Churn
GROUP BY
    IsActiveMember,
    Exited
ORDER BY
    IsActiveMember,
    Exited;
    
    SELECT
    CASE
        WHEN Tenure BETWEEN 0 AND 2 THEN 'New Customers (0-2)'
        WHEN Tenure BETWEEN 3 AND 5 THEN 'Medium-Term (3-5)'
        WHEN Tenure BETWEEN 6 AND 10 THEN 'Long-Term (6-10)'
    END AS Customer_Segment,
	COUNT(CustomerId) AS Total_Customers,
	ROUND(AVG(Balance), 2) AS Average_Balance,
	ROUND(AVG(NumOfProducts), 2) AS Average_Products,
	SUM(Exited) AS Exited_Customers,
	ROUND(
        SUM(Exited) * 100.0 / COUNT(CustomerId), 2
    ) AS Churn_Rate
FROM Bank_Churn
GROUP BY Customer_Segment
ORDER BY MIN(Tenure);

SELECT
    NumOfProducts,
    HasCrCard,
    COUNT(CustomerId) AS Total_Customers,
    SUM(Exited) AS Exited_Customers,
    ROUND(
        SUM(Exited) * 100.0 / COUNT(CustomerId), 2
    ) AS Churn_Rate
FROM Bank_Churn
GROUP BY NumOfProducts, HasCrCard
ORDER BY Total_Customers DESC;

SELECT
    g.GeographyLocation AS Region,
    COUNT(b.CustomerId) AS Total_Customers,
    SUM(b.IsActiveMember) AS Active_Customers,
    SUM(b.Exited) AS Exited_Customers,
    ROUND(
        SUM(b.Exited) * 100.0 / COUNT(b.CustomerId), 2
    ) AS Churn_Rate,
    ROUND(AVG(b.Balance), 2) AS Average_Balance
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
JOIN Geography g
    ON c.GeographyID = g.GeographyID
GROUP BY g.GeographyLocation
ORDER BY Churn_Rate DESC;

SELECT
    CASE
        WHEN c.Age < 30 THEN 'Below 30'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60 and Above'
    END AS Age_Group,
    COUNT(b.CustomerId) AS Total_Customers,
    SUM(b.Exited) AS Exited_Customers,
    ROUND(
        SUM(b.Exited) * 100.0 / COUNT(b.CustomerId), 2
    ) AS Churn_Rate
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
GROUP BY Age_Group
ORDER BY Churn_Rate DESC;

SELECT
    CASE
        WHEN b.Tenure BETWEEN 0 AND 2 THEN 'New Customers (0-2)'
        WHEN b.Tenure BETWEEN 3 AND 5 THEN 'Medium-Term (3-5)'
        ELSE 'Long-Term (6-10)'
    END AS Customer_Segment,
    COUNT(b.CustomerId) AS Total_Customers,
    ROUND(AVG(b.Tenure), 2) AS Average_Tenure,
    ROUND(AVG(b.Balance), 2) AS Average_Balance,
    ROUND(AVG(b.NumOfProducts), 2) AS Average_Products,
    ROUND(
        SUM(b.Exited) * 100.0 / COUNT(b.CustomerId), 2
    ) AS Churn_Rate
FROM Bank_Churn b
GROUP BY Customer_Segment
ORDER BY MIN(b.Tenure);

SELECT
    YEAR(Bank_DOJ_Date) AS Joining_Year,
    COUNT(CustomerId) AS Customers_Acquired
FROM CustomerInfo
GROUP BY YEAR(Bank_DOJ_Date)
ORDER BY Joining_Year;

SELECT
    Tenure,
    NumOfProducts,
    COUNT(CustomerId) AS Exited_Customers,
    ROUND(AVG(Balance), 2) AS Average_Balance
FROM Bank_Churn
WHERE Exited = 1
GROUP BY Tenure, NumOfProducts
ORDER BY Exited_Customers DESC
LIMIT 10;

SELECT
    CASE
        WHEN c.EstimatedSalary < 50000 THEN 'Below 50000'
        WHEN c.EstimatedSalary BETWEEN 50000 AND 100000 THEN '50000-100000'
        WHEN c.EstimatedSalary BETWEEN 100001 AND 150000 THEN '100001-150000'
        ELSE 'Above 150000'
    END AS Salary_Group,
    COUNT(b.CustomerId) AS Total_Customers,
    SUM(b.Exited) AS Exited_Customers,
    ROUND(
        SUM(b.Exited) * 100.0 / COUNT(b.CustomerId), 2
    ) AS Churn_Rate
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
GROUP BY Salary_Group
ORDER BY Churn_Rate DESC;

SELECT b.CustomerId, c.Age, g.GenderCategory AS Gender, geo.GeographyLocation AS Region, b.Tenure, b.NumOfProducts, b.HasCrCard, b.IsActiveMember, b.Balance,
    CASE
        WHEN c.Age < 30 THEN 'Young'
        WHEN c.Age BETWEEN 30 AND 49 THEN 'Middle-Aged'
        ELSE 'Senior'
    END AS Age_Segment,
    CASE
        WHEN b.Balance = 0 THEN 'Zero Balance'
        WHEN b.Balance < 50000 THEN 'Low Balance'
        WHEN b.Balance <= 100000 THEN 'Medium Balance'
        ELSE 'High Balance'
    END AS Balance_Segment,
    CASE
        WHEN b.Exited = 1 THEN 'Exited'
        ELSE 'Retained'
    END AS Customer_Status
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
JOIN Gender g
    ON c.GenderID = g.GenderID
JOIN Geography geo
    ON c.GeographyID = geo.GeographyID;
    
SELECT
    YEAR(c.Bank_DOJ_Date) AS Joining_Year,
    COUNT(*) AS Total_Customers,
    SUM(b.Exited) AS Exited_Customers,
    ROUND(
        SUM(b.Exited) * 100.0 / COUNT(*), 2
    ) AS Churn_Rate_Percentage
FROM Bank_Churn b
JOIN CustomerInfo c
    ON b.CustomerId = c.CustomerId
GROUP BY YEAR(c.Bank_DOJ_Date)
ORDER BY Joining_Year;

ALTER TABLE Bank_Churn
RENAME COLUMN HasCrCard TO Has_creditcard;

