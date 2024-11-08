
-- SQL Script for ES Data Analysis

-- Create a table for ES data
CREATE TABLE es_data (
    Time DATETIME,
    Open FLOAT,
    High FLOAT,
    Low FLOAT,
    Close FLOAT,
    Volume INT
);

-- Load data into es_data table (assume data is being loaded via some ETL process)
-- INSERT INTO es_data (Time, Open, High, Low, Close, Volume) VALUES (...);

-- Query to inspect ES data
SELECT * FROM es_data
LIMIT 10;

-- Aggregating data to daily level
SELECT
    DATE(Time) as Date,
    MIN(Open) as Open,
    MAX(High) as High,
    MIN(Low) as Low,
    MAX(Close) as Close,
    SUM(Volume) as Volume
FROM
    es_data
GROUP BY
    DATE(Time);

-- Calculate daily returns
SELECT
    Date,
    Close,
    LAG(Close, 1) OVER (ORDER BY Date) AS Prev_Close,
    (Close - LAG(Close, 1) OVER (ORDER BY Date)) / LAG(Close, 1) OVER (ORDER BY Date) AS Daily_Return
FROM
    (SELECT
        DATE(Time) as Date,
        MAX(Close) as Close
     FROM
        es_data
     GROUP BY
        DATE(Time)) as daily_close;

-- Identify significant daily changes (e.g., returns > 2%)
SELECT
    Date,
    Close,
    Daily_Return
FROM
    (SELECT
        Date,
        Close,
        (Close - LAG(Close, 1) OVER (ORDER BY Date)) / LAG(Close, 1) OVER (ORDER BY Date) AS Daily_Return
     FROM
        (SELECT
            DATE(Time) as Date,
            MAX(Close) as Close
         FROM
            es_data
         GROUP BY
            DATE(Time)) as daily_close) as returns
WHERE
    ABS(Daily_Return) > 0.02;
