-- Retrieve All Properties in Sydney
SELECT * FROM SydneyProperties;

-- Get Average Rent Amount for Each Property Type
SELECT PropertyType, AVG(RentAmount) AS AvgRent
FROM SydneyProperties
GROUP BY PropertyType;

-- Find Properties with Rent Above a Certain Threshold
SELECT * FROM SydneyProperties
WHERE RentAmount > 3000;

-- Count the Number of Properties in Each Suburb
SELECT Suburb, COUNT(*) AS PropertyCount
FROM SydneyProperties
GROUP BY Suburb;

-- Retrieve the Latest Available Properties
SELECT *
FROM SydneyProperties
WHERE Availability > NOW();

-- Calculate the Total Rent Collected in the Last Month
SELECT SUM(RentAmount) AS TotalRent
FROM SydneyProperties
WHERE Timestamp >= CURRENT_DATE - INTERVAL '1 month';

-- Identify Suburbs with the Highest Average Rent
SELECT Suburb, AVG(RentAmount) AS AvgRent
FROM SydneyProperties
GROUP BY Suburb
ORDER BY AvgRent DESC
LIMIT 5;

-- Retrieve Properties with 3 or More Bedrooms
SELECT *
FROM SydneyProperties
WHERE Bedrooms >= 3;

-- Calculate Rent Increase Percentage Over Two Years
SELECT PropertyID, 
       (MAX(RentAmount) - MIN(RentAmount)) / MIN(RentAmount) * 100 AS RentIncreasePercentage
FROM SydneyProperties
WHERE Timestamp >= '2021-01-01' AND Timestamp < '2023-01-01'
GROUP BY PropertyID;

-- Find Properties Where Rent Amount Exceeds 30% of Household Income
SELECT *
FROM SydneyProperties
WHERE RentAmount > 0.3 * HouseholdIncome;

-- Calculate the Monthly Rent Sum for Each Property Type
SELECT PropertyType, DATE_TRUNC('month', Timestamp) AS Month,
       SUM(RentAmount) AS MonthlyRentSum
FROM SydneyProperties
GROUP BY PropertyType, Month;

-- Identify Suburbs with the Most Expensive Properties
WITH RankedSuburbs AS (
    SELECT Suburb, AVG(RentAmount) AS AvgRent,
           ROW_NUMBER() OVER (ORDER BY AVG(RentAmount) DESC) AS Rank
    FROM SydneyProperties
    GROUP BY Suburb
)
SELECT Suburb, AvgRent
FROM RankedSuburbs
WHERE Rank <= 5;

-- Retrieve Properties Available for Rent in the Next 30 Days
SELECT *
FROM SydneyProperties
WHERE Availability BETWEEN NOW() AND NOW() + INTERVAL 30 DAY;

-- Calculate Rent-to-Income Ratio for Each Property
SELECT PropertyID, RentAmount / HouseholdIncome AS RentToIncomeRatio
FROM SydneyProperties;

-- Identify Properties with Unusual Rent Patterns Using Standard Deviation
WITH RentStats AS (
    SELECT PropertyID, AVG(RentAmount) AS AvgRent, STDDEV(RentAmount) AS RentStdDev
    FROM SydneyProperties
    GROUP BY PropertyID
)
SELECT PropertyID, AvgRent, RentStdDev
FROM RentStats
WHERE RentAmount > AvgRent + 2 * RentStdDev;

-- Retrieve Properties with the Same Rent as Another Property
SELECT a.PropertyID, a.Address, a.RentAmount
FROM SydneyProperties a
JOIN SydneyProperties b ON a.RentAmount = b.RentAmount
WHERE a.PropertyID <> b.PropertyID;

-- Calculate the Cumulative Rent for Each Property Over Time
SELECT PropertyID, Timestamp, RentAmount,
       SUM(RentAmount) OVER (PARTITION BY PropertyID ORDER BY Timestamp) AS CumulativeRent
FROM SydneyProperties;

-- Identify Properties with a Significant Rent Drop in the Last 3 Months
WITH RentChanges AS (
    SELECT PropertyID, MAX(RentAmount) - MIN(RentAmount) AS RentDrop
    FROM SydneyProperties
    WHERE Timestamp >= CURRENT_DATE - INTERVAL '3 months'
    GROUP BY PropertyID
)
SELECT PropertyID, RentDrop
FROM RentChanges
ORDER BY RentDrop DESC
LIMIT 5;

-- Retrieve the Latest Rent Amount for Each Property
SELECT DISTINCT ON (PropertyID) PropertyID, Address, RentAmount
FROM SydneyProperties
ORDER BY PropertyID, Timestamp DESC;

-- Calculate the Median Rent for Each Suburb
SELECT Suburb, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY RentAmount) AS MedianRent
FROM SydneyProperties
GROUP BY Suburb;

-- Identify Properties with a Rent Amount Higher Than the Suburb's Average
WITH SuburbAvgRent AS (
    SELECT Suburb, AVG(RentAmount) AS AvgRent
    FROM SydneyProperties
    GROUP BY Suburb
)
SELECT a.PropertyID, a.Address, a.RentAmount, b.AvgRent
FROM SydneyProperties a
JOIN SuburbAvgRent b ON a.Suburb = b.Suburb
WHERE a.RentAmount > b.AvgRent;

-- Calculate the Average Rent Increase Percentage Over the Last 12 Months
SELECT PropertyID, 
       AVG((RentAmount - LAG(RentAmount) OVER (PARTITION BY PropertyID ORDER BY Timestamp)) / LAG(RentAmount) OVER (PARTITION BY PropertyID ORDER BY Timestamp) * 100) AS AvgRentIncrease
FROM SydneyProperties
WHERE Timestamp >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY PropertyID;

-- Retrieve the Top 5 Most Expensive Properties in Each Suburb
WITH RankedProperties AS (
    SELECT PropertyID, Address, RentAmount,
           ROW_NUMBER() OVER (PARTITION BY Suburb ORDER BY RentAmount DESC) AS Rank
    FROM SydneyProperties
)
SELECT PropertyID, Address, RentAmount
FROM RankedProperties
WHERE Rank <= 5;

-- Calculate the Rent Change Percentage Compared to the Previous Month
SELECT PropertyID, Address, Timestamp, RentAmount,
       (RentAmount - LAG(RentAmount) OVER (PARTITION BY PropertyID ORDER BY Timestamp)) / LAG(RentAmount) OVER (PARTITION BY PropertyID ORDER BY Timestamp) * 100 AS RentChangePercentage
FROM SydneyProperties;

-- Identify Properties with a Steady Increase in Rent over the Last Year
WITH RentChanges AS (
    SELECT PropertyID, AVG(RentAmount) AS AvgRent,
           COUNT(CASE WHEN RentAmount > LAG(RentAmount) OVER (PARTITION BY PropertyID ORDER BY Timestamp) THEN 1 END) AS RentIncreases
    FROM SydneyProperties
    WHERE Timestamp >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY PropertyID
)
SELECT PropertyID, AvgRent, RentIncreases
FROM RentChanges
WHERE RentIncreases >= 10;
