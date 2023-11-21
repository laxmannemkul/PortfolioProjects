-- Calculate Daily Price Change and Percentage Change for All Cryptocurrencies
SELECT Symbol, Timestamp, Price,
       LAG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp) AS PreviousPrice,
       Price - LAG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp) AS PriceChange,
       ((Price - LAG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp)) / LAG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp)) * 100 AS PercentageChange
FROM CryptoPrices
ORDER BY Symbol, Timestamp;

-- Identify Cryptocurrencies with the Highest and Lowest Daily Volatility
WITH VolatilityData AS (
    SELECT Symbol, AVG(PriceChange) AS AvgDailyChange
    FROM (
        SELECT Symbol, 
               Price - LAG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp) AS PriceChange
        FROM CryptoPrices
    ) AS DailyChanges
    GROUP BY Symbol
)
SELECT Symbol, AvgDailyChange
FROM VolatilityData
ORDER BY AvgDailyChange DESC
LIMIT 5 -- Top 5 most volatile
UNION ALL
SELECT Symbol, AvgDailyChange
FROM VolatilityData
ORDER BY AvgDailyChange ASC
LIMIT 5; -- Top 5 least volatile

-- Calculate Rolling Average Price for a Specific Cryptocurrency
SELECT Symbol, Timestamp, Price,
       AVG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) AS SevenDayAvgPrice
FROM CryptoPrices
WHERE Symbol = 'BTC'
ORDER BY Timestamp;

-- Identify Cryptocurrencies with Consistent Positive Price Trends
WITH PositiveTrends AS (
    SELECT Symbol,
           COUNT(CASE WHEN PriceChange > 0 THEN 1 END) AS PositiveChanges,
           COUNT(*) AS TotalChanges
    FROM (
        SELECT Symbol, 
               Price - LAG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp) AS PriceChange
        FROM CryptoPrices
    ) AS DailyChanges
    GROUP BY Symbol
)
SELECT Symbol, PositiveChanges, TotalChanges,
       (PositiveChanges / TotalChanges) * 100 AS PercentagePositiveChanges
FROM PositiveTrends
ORDER BY PercentagePositiveChanges DESC
LIMIT 10; -- Top 10 with consistent positive trends

-- Calculate Average Monthly Price for All Cryptocurrencies
SELECT Symbol,
       DATE_TRUNC('month', Timestamp) AS MonthStart,
       AVG(Price) AS AvgMonthlyPrice
FROM CryptoPrices
GROUP BY Symbol, MonthStart
ORDER BY Symbol, MonthStart;

-- Identify Cryptocurrencies with the Best Monthly Performance
WITH MonthlyPerformance AS (
    SELECT Symbol,
           DATE_TRUNC('month', Timestamp) AS MonthStart,
           MAX(Price) - MIN(Price) AS MonthlyPerformance
    FROM CryptoPrices
    GROUP BY Symbol, MonthStart
)
SELECT Symbol, MonthStart, MonthlyPerformance
FROM MonthlyPerformance
ORDER BY MonthlyPerformance DESC
LIMIT 5; -- Top 5 best monthly performers

-- Calculate 30-Day Rolling Volatility for a Specific Cryptocurrency
SELECT Symbol, Timestamp, Price,
       SQRT(SUM(POWER(PriceChange, 2)) / COUNT(PriceChange)) AS RollingVolatility
FROM (
    SELECT Symbol, 
           Price - LAG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp) AS PriceChange
    FROM CryptoPrices
) AS DailyChanges
WHERE Symbol = 'ETH'
GROUP BY Symbol, Timestamp
ORDER BY Timestamp;

-- Identify Cryptocurrencies with the Highest Price Increase in the Last 7 Days
WITH Last7DaysPerformance AS (
    SELECT Symbol, MAX(Price) AS LatestPrice, MIN(Price) AS EarliestPrice
    FROM CryptoPrices
    WHERE Timestamp >= CURRENT_DATE - INTERVAL '7 days'
    GROUP BY Symbol
)
SELECT Symbol,
       (LatestPrice - EarliestPrice) / EarliestPrice * 100 AS PercentageChange
FROM Last7DaysPerformance
ORDER BY PercentageChange DESC
LIMIT 5; -- Top 5 performers in the last 7 days

-- Calculate Exponential Moving Average (EMA) for Cryptocurrency Prices
SELECT Symbol, Timestamp, Price,
       AVG(Price) OVER (PARTITION BY Symbol ORDER BY Timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SimpleMovingAvg,
       EXP(AVG(LN(Price)) OVER (PARTITION BY Symbol ORDER BY Timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS ExponentialMovingAvg
FROM CryptoPrices
WHERE Symbol = 'ETH'
ORDER BY Timestamp;

-- Find Cryptocurrencies with the Highest Trading Volume
SELECT Symbol, SUM(Volume) AS TotalVolume
FROM CryptoPrices
GROUP BY Symbol
ORDER BY TotalVolume DESC
LIMIT 5; -- Top 5 cryptocurrencies by trading volume

-- Identify Correlations between Cryptocurrency Prices
SELECT A.Symbol AS Symbol1, B.Symbol AS Symbol2,
       CORR(A.Price, B.Price) AS PriceCorrelation
FROM CryptoPrices A
JOIN CryptoPrices B ON A.Timestamp = B.Timestamp
WHERE A.Symbol < B.Symbol
GROUP BY Symbol1, Symbol2
ORDER BY PriceCorrelation DESC
LIMIT 5; -- Top 5 correlated cryptocurrency pairs

-- Calculate the Average Return on Investment (ROI) for Cryptocurrencies
SELECT Symbol,
       (MAX(Price) - MIN(Price)) / MIN(Price) * 100 AS ROI
FROM CryptoPrices
GROUP BY Symbol
ORDER BY ROI DESC
LIMIT 10; -- Top 10 cryptocurrencies with the highest ROI

-- Identify Cryptocurrencies with Abnormal Price Movements (Outliers)
SELECT Symbol, Price, 
       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price) OVER (PARTITION BY Symbol) AS Q1,
       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price) OVER (PARTITION BY Symbol) AS Q3
FROM CryptoPrices
WHERE Symbol = 'BTC'
HAVING Price < Q1 - 1.5 * (Q3 - Q1) OR Price > Q3 + 1.5 * (Q3 - Q1)
ORDER BY Price;
