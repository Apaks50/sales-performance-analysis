CREATE DATABASE SalesPerformance_db
SELECT name FROM sys.databases;
USE SalesPerformance_db;
SELECT COUNT(*) AS Total_Rows FROM dbo.SalesData_Cleaned;
SELECT TOP 20 * FROM dbo.SalesData_Cleaned;
EXEC sp_help 'dbo.SalesData_Cleaned';
--Total recorded sales value
SELECT
    SUM(Total_Price) AS Total_Recorded_Value
FROM dbo.SalesData_Cleaned;
--Deleted records
SELECT
    Is_Deleted,
    COUNT(*) AS Total_Records
FROM dbo.SalesData_Cleaned
GROUP BY Is_Deleted;
--Order statuses
SELECT
    Item_Status,
    COUNT(*) AS Total_Items
FROM dbo.SalesData_Cleaned
GROUP BY Item_Status
ORDER BY Total_Items DESC;
--Calculate actual delivered revenue
SELECT
    SUM(Total_Price) AS Delivered_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered';
--Calculate total delivered quantity
SELECT
    SUM(TRY_CAST(Quantity AS BIGINT)) AS Total_Quantity_Sold
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered';
--Calculated cancelled sales value
SELECT
    SUM(Total_Price) AS Cancelled_Value
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Cancelled';
--The top 10 best selling products
SELECT TOP 10
    Item_Name,
    SUM(TRY_CAST(Quantity AS BIGINT)) AS Total_Quantity,
    SUM(Total_Price) AS Total_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Item_Name
ORDER BY Total_Revenue DESC;
--The least performing products
SELECT TOP 10
    Item_Name,
    SUM(TRY_CAST(Quantity AS BIGINT)) AS Total_Quantity,
    SUM(Total_Price) AS Total_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Item_Name
ORDER BY Total_Revenue ASC;
--Top 10 vendors by revenue
SELECT TOP 10
    Business_Name,
    SUM(TRY_CAST(Quantity AS BIGINT)) AS Total_Quantity,
    SUM(Total_Price) AS Total_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Business_Name
ORDER BY Total_Revenue DESC;
--Bottom 10 vendors by revenue
SELECT TOP 10
    Business_Name,
    SUM(TRY_CAST(Quantity AS BIGINT)) AS Total_Quantity,
    SUM(Total_Price) AS Total_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Business_Name
ORDER BY Total_Revenue ASC;
--Revenue by region
SELECT
    Order_Region,
    SUM(TRY_CAST(Quantity AS BIGINT)) AS Total_Quantity,
    SUM(Total_Price) AS Total_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Order_Region
ORDER BY Total_Revenue DESC;
--Revenue by local Government Area
SELECT TOP 10
    Order_Local_Area,
    SUM(Total_Price) AS Total_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Order_Local_Area
ORDER BY Total_Revenue DESC;
--Calculate monthly revenue
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(TRY_CAST(Quantity AS BIGINT)) AS Total_Quantity,
    SUM(Total_Price) AS Monthly_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Sales_Year,
    Sales_Month;
--Calculate monthly order count
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Total_Price) AS Monthly_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Sales_Year,
    Sales_Month;
--Average Order Value
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Total_Price) AS Total_Revenue,
    SUM(Total_Price) / NULLIF(COUNT(DISTINCT Order_ID), 0)
        AS Average_Order_Value
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Sales_Year,
    Sales_Month;
--Branch performance analysis
SELECT
    Branch_Location,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(TRY_CAST(Quantity AS BIGINT)) AS Total_Quantity,
    SUM(Total_Price) AS Total_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Branch_Location
ORDER BY Total_Revenue DESC;
--Vendor performance analysis
SELECT
    Branch_Name,
    SUM(Total_Price) AS Total_Revenue
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Branch_Name
ORDER BY Total_Revenue DESC;
--checking quantity column
SELECT
    Quantity,
    TRY_CONVERT(DECIMAL(18,2), Quantity) AS Converted_Quantity
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered';
--checking invalid quantities
SELECT
    COUNT(*) AS Total_Records,
    COUNT(TRY_CONVERT(DECIMAL(18,2), Quantity)) AS Successfully_Converted
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered';
--Data quality analysis
SELECT
    COUNT(*) AS Total_Records,

    SUM(CASE WHEN Item_Name IS NULL
        OR LTRIM(RTRIM(Item_Name)) = ''
        THEN 1 ELSE 0 END) AS Missing_Item_Name,

    SUM(CASE WHEN Quantity IS NULL
        OR Quantity <= 0
        THEN 1 ELSE 0 END) AS Invalid_Quantity,

    SUM(CASE WHEN Total_Price IS NULL
        OR Total_Price <= 0
        THEN 1 ELSE 0 END) AS Invalid_Total_Price

FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered';
--checking invalid quantities
SELECT
    COUNT(*) AS Invalid_Quantity
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
AND (
    TRY_CONVERT(DECIMAL(18,2), Quantity) IS NULL
    OR TRY_CONVERT(DECIMAL(18,2), Quantity) <= 0
);
--check missing product names
SELECT
    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Item_Name IS NULL
              OR LTRIM(RTRIM(Item_Name)) = ''
            THEN 1
            ELSE 0
        END
    ) AS Missing_Item_Name

FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered';
--check duplicate records
SELECT
    Order_ID,
    Item_ID,
    COUNT(*) AS Duplicate_Count
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Order_ID, Item_ID
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;
--Inspect the repeated records
SELECT *
FROM dbo.SalesData_Cleaned
WHERE Order_ID = '3897'
AND Item_ID = '5fcf9cc73262da995e0d1a8f';
--check order item number
SELECT
    Order_Item_Number,
    COUNT(*) AS Record_Count
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered'
GROUP BY Order_Item_Number
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;
--inspect one repeated order item number
SELECT *
FROM dbo.SalesData_Cleaned
WHERE Order_Item_Number = 'ML0JJH0LE0OKUD9OWD4QVIVQ';
--check all repeated order item identifiers
SELECT
    COUNT(*) AS Repeated_Identifiers,
    SUM(Record_Count) AS Total_Affected_Records
FROM (
    SELECT
        Order_Item_Number,
        COUNT(*) AS Record_Count
    FROM dbo.SalesData_Cleaned
    WHERE Item_Status = 'Delivered'
    GROUP BY Order_Item_Number
    HAVING COUNT(*) > 1
) AS Duplicate_Check;
--check is deleted
SELECT
    Is_Deleted,
    COUNT(*) AS Total_Records
FROM dbo.SalesData_Cleaned
GROUP BY Is_Deleted;
--check the order date column
SELECT
    MIN(Order_Date) AS First_Order_Date,
    MAX(Order_Date) AS Last_Order_Date,
    COUNT(DISTINCT CAST(Order_Date AS DATE)) AS Number_Of_Sales_Days
FROM dbo.SalesData_Cleaned
WHERE Item_Status = 'Delivered';
