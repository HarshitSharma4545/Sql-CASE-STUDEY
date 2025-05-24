

select * from orders
select * from CUSTOMERS

SELECT ORDER_NUMBER,CUSTOMER_KEY,ORDER_TOTAL
FROM ORDERS
WHERE CUSTOMER_KEY IN (SELECT CUSTOMER_KEY FROM CUSTOMERS)

--  Q1. Total Revenue (order value)
select SUM(try_cast(order_total as decimal(10,2))) as Revenue from orders
select sum(try_cast(order_total as  float)) as revenue from orders
 
--Q2. Total Revenue (order value) by top 25 Customers 
SELECT top 25 CUSTOMER_KEY, 
       SUM(try_cast(ORDER_TOTAL as Decimal(10,2))) AS TOTAL_REVENUE
FROM ORDERS
GROUP BY CUSTOMER_KEY
ORDER BY TOTAL_REVENUE DESC

--Q3. Total number of orders 
SELECT COUNT(*) AS TOTAL_ORDERS
FROM Orders;

--Q4. Total orders by top 10 customers 
select top 10 customer_key, count('ORDERS') as total_order from ORDERS
group by ORDER_TOTAL,customer_key
order by total_order desc
--Q6. Number of customers ordered once - 
SELECT COUNT(*) AS CustomersOrderedOnce
FROM (
    SELECT CUSTOMER_KEY
    FROM Orders
    GROUP BY CUSTOMER_KEY
    HAVING COUNT('ORDERS') = 1
) AS SingleOrderCustomers;

--Q7. Number of customers ordered multiple times 
SELECT COUNT(*) AS OrderedMultipleTimes
FROM (
    SELECT CUSTOMER_KEY
    FROM Orders
    GROUP BY CUSTOMER_KEY
    HAVING COUNT('ORDERS') > 1
) AS MultipleOrderCustomers;

--Q8. Number of customers referred to other customers 
SELECT COUNT(*) AS NumberOfCustomersReferred
FROM CUSTOMERS
WHERE 'Referred Other customers' = 'Y';

--Q9. Which Month have maximum Revenue? 
SELECT top 1
    FORMAT(CONVERT(DATE, ORDER_DATE, 103), 'yyyy-MM') AS Month,
    SUM(try_cast(ORDER_TOTAL as decimal(10,2))) AS Total_Revenue
FROM
    Orders
GROUP BY
    FORMAT(CONVERT(DATE, ORDER_DATE, 103), 'yyyy-MM')
ORDER BY
    Total_Revenue DESC

--Q10. Number of customers are inactive (that haven't ordered in the last 60 days)  

  SELECT COUNT(DISTINCT C.CUSTOMER_KEY) AS InactiveCustomers 
  FROM CUSTOMERS C
LEFT JOIN
    Orders O ON C.CUSTOMER_KEY = O.CUSTOMER_KEY
WHERE
    O.ORDER_DATE IS NULL 
    OR TRY_CONVERT(DATE, O.ORDER_DATE) < DATEADD(DAY, -60, GETDATE())

--Q11. Growth Rate  (%) in Orders (from Nov’15 to July’16)  -
SELECT
    (SUM(CASE WHEN YEAR(CONVERT(DATE, ORDER_DATE, 103)) = 2016 AND MONTH(CONVERT(DATE, ORDER_DATE, 103)) <= 7 THEN 1 ELSE 0 END) - 
    SUM(CASE WHEN YEAR(CONVERT(DATE, ORDER_DATE, 103)) = 2015 AND MONTH(CONVERT(DATE, ORDER_DATE, 103)) = 11 THEN 1 ELSE 0 END)) * 100.0 /
    NULLIF(SUM(CASE WHEN YEAR(CONVERT(DATE, ORDER_DATE, 103)) = 2015 AND MONTH(CONVERT(DATE, ORDER_DATE, 103)) = 11 THEN 1 ELSE 0 END), 0) AS Growth_Rate_Percentage
FROM  Orders
WHERE
    CONVERT(DATE, ORDER_DATE, 103) BETWEEN '2015-11-01' AND '2016-07-31';

--Q12. Growth Rate (%) in Revenue (from Nov'15 to July'16)  
SELECT
    (SUM(CASE 
            WHEN YEAR(CONVERT(DATE, ORDER_DATE, 103)) = 2016 
                 AND MONTH(CONVERT(DATE, ORDER_DATE, 103)) <= 7 
                 AND ISNUMERIC(ORDER_TOTAL) = 1
            THEN CAST(ORDER_TOTAL AS DECIMAL(18, 2)) 
            ELSE 0 
         END) -
    SUM(CASE 
            WHEN YEAR(CONVERT(DATE, ORDER_DATE, 103)) = 2015 
                 AND MONTH(CONVERT(DATE, ORDER_DATE, 103)) = 11 
                 AND ISNUMERIC(ORDER_TOTAL) = 1
            THEN CAST(ORDER_TOTAL AS DECIMAL(18, 2)) 
            ELSE 0 
         END)) * 100.0 /
    NULLIF(SUM(CASE 
                   WHEN YEAR(CONVERT(DATE, ORDER_DATE, 103)) = 2015 
                        AND MONTH(CONVERT(DATE, ORDER_DATE, 103)) = 11 
                        AND ISNUMERIC(ORDER_TOTAL) = 1
                   THEN CAST(ORDER_TOTAL AS DECIMAL(18, 2)) 
                   ELSE 0 
                END), 0) AS Revenue_Growth_Rate_Percentage
FROM
    Orders
WHERE
    CONVERT(DATE, ORDER_DATE, 103) BETWEEN '2015-11-01' AND '2016-07-31';

--Q13. What is the percentage of Male customers exists?  
SELECT
    (COUNT(CASE WHEN Gender = 'M' THEN 1 END) * 100.0) / COUNT(*) AS Percentage_Male_Customers
FROM
    CUSTOMERS;
--Q14. Which location have maximum customers?  
SELECT top 4
    Location,
    COUNT(*) AS Customer_Count
FROM
    CUSTOMERS
GROUP BY
    Location
ORDER BY
    Customer_Count DESC



--Q15. How many orders are returned? (Returns can be found if the order total value is negative value)
SELECT
    COUNT(*) AS Returned_Orders_Count
FROM
    Orders
WHERE
    TRY_CONVERT(DECIMAL(18, 2), ORDER_TOTAL) < 0;

--Q16. Which Acquisition channel is more efficient in terms of customer acquisition? 
SELECT
    [Acquired Channel],
    COUNT(*) AS Customer_Count
FROM
    CUSTOMERS
GROUP BY
    [Acquired Channel]
ORDER BY
    Customer_Count DESC;

--Q17. Which location having more orders with discount amount? 
SELECT  c.Location,  COUNT(o.'ORDER') AS Total_Discounted_Orders
FROM  orders o
JOIN   customers c ON  o.CUSTOMER_KEY = c.CUSTOMER_KEY
WHERE 
    TRY_CAST(o.DISCOUNT AS DECIMAL(10, 2)) > 0
GROUP BY 
    c.Location
ORDER BY 
    Total_Discounted_Orders DESC;
--Q18. Which location having maximum orders delivered in delay?
SELECT 
    c.Location, 
    COUNT(o.'ORDERS') AS Total_Delayed_Orders
FROM 
    orders o
JOIN 
    customers c 
ON 
    o.CUSTOMER_KEY = c.CUSTOMER_KEY
WHERE 
    o.DELIVERY_STATUS = 'LATE'
GROUP BY 
    c.Location
ORDER BY 
    Total_Delayed_Orders DESC;

--Q19.What is the percentage of customers who are males acquired by APP channel? 
SELECT 
    (COUNT(CASE WHEN Gender = 'M' AND "Acquired Channel" = 'APP' THEN 1 END) * 100.0 / COUNT(*)) AS Percentage_Male_Customers_APP
FROM 
    customer;

--Q20. What is the percentage of orders got canceled?  
SELECT 
    (COUNT(CASE WHEN ORDER_STATUS = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*)) AS Percentage_Cancelled_Orders
FROM 
    orders;
--Q21. What is the percentage of orders done by happy customers (Note: Happy customers mean customer who referred other customers)? 
SELECT 
    (COUNT(CASE WHEN c.[Referred Other Customers] = 'Y' THEN 1 END) * 100.0 / COUNT(*)) AS Percentage_Orders_By_Happy_Customers
FROM 
    orders o
JOIN 
    customer c 
ON 
    o.CUSTOMER_KEY = c.CUSTOMER_KEY;

--Q22. Which Location having maximum customers through reference?
SELECT 
    Location,
    COUNT(CUSTOMER_KEY) AS Total_Referenced_Customers
FROM 
    customer
WHERE 
    [Referred Other Customers] = 'Y'
GROUP BY 
    Location
ORDER BY 
    Total_Referenced_Customers DESC;

--Q23. What is order_total value of male customers who are belongs to Chennai and Happy customers (Happy customer definition is same in question 21)?  - 3 Marks
SELECT 
    SUM(try_cast(o.ORDER_TOTAL as decimal(10,2))) AS Total_Order_Value
FROM 
    orders o
JOIN 
    customer c 
ON 
    o.CUSTOMER_KEY = c.CUSTOMER_KEY
WHERE 
    c.Gender = 'M'
    AND c.Location = 'Chennai'
    AND c.[Referred Other Customers] = 'Y';
--Q24. Which month having maximum order value from male customers belongs to Chennai?  
SELECT 
    DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Month,
    DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Year,
    SUM(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2))) AS Total_Order_Value
FROM orders o
JOIN customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
WHERE  c.Gender = 'M' AND c.Location = 'Chennai'
GROUP BY 
    DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)),
    DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE))
ORDER BY  Total_Order_Value DESC

--Q26. Prepare at least 5 additional analysis on your own?
--1. Monthly Sales Trend by Location
SELECT  DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)) AS Month,
    c.Location, SUM(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2))) AS Total_Sales
FROM  orders o
JOIN  customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY  DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)),
    c.Location
ORDER BY  Month, c.Location;
--2. Customer Acquisition Channels Performance
SELECT 
    [Acquired Channel],
    SUM(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2))) AS Total_Sales
FROM 
    orders o
JOIN 
    customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY 
    [Acquired Channel]
ORDER BY 
    Total_Sales DESC;
--3. Average Order Value by Gender and Location
SELECT  c.Location, c.Gender,
  AVG(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2))) AS Avg_Order_Value
FROM orders o JOIN customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY  c.Location, c.Gender
ORDER BY  c.Location, c.Gender;
--4. Order Cancellation Rate by Location
SELECT 
    c.Location,
    COUNT(CASE WHEN o.ORDER_STATUS = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*) AS Cancellation_Rate
FROM 
    orders o
JOIN 
    customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY 
    c.Location
ORDER BY 
    Cancellation_Rate DESC;
--5.Top 5 Customers by Total Order Value
SELECT 
    c.CUSTOMER_KEY,
    SUM(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2))) AS Total_Spent
FROM 
    orders o
JOIN 
    customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY 
    c.CUSTOMER_KEY
ORDER BY 
    Total_Spent DESC

--Q25. What are number of discounted orders ordered by female customers who were acquired by website from Bangalore delivered on time?  - 3 Marks
SELECT 
    COUNT(*) AS Number_Of_Discounted_Orders
FROM 
    orders o
JOIN 
    customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
WHERE 
    c.Gender = 'F'
    AND c.[Acquired Channel] = 'WEBSITE'
    AND c.Location = 'Bangalore'
    AND o.DELIVERY_STATUS = 'ON-TIME'
    AND TRY_CAST(o.DISCOUNT AS DECIMAL(10,2)) > 0;
--Q26. Number of orders by month based on order status (Delivered vs. canceled vs. etc.) - Split of order status by month  - 3 Marks
SELECT 
    DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Year,
    DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Month,
    o.ORDER_STATUS, COUNT(*) AS Number_Of_Orders
FROM  orders o
WHERE  TRY_CAST(o.ORDER_DATE AS DATE) IS NOT NULL
GROUP BY 
    DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)),
    DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)),
    o.ORDER_STATUS
ORDER BY   Order_Year,  Order_Month,  o.ORDER_STATUS  
--Q27. Number of orders by month based on delivery status  - 3 Marks
SELECT 
    DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Year,
    DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Month,
    o.DELIVERY_STATUS,
    COUNT(*) AS Number_Of_Orders
FROM   orders o
WHERE  TRY_CAST(o.ORDER_DATE AS DATE) IS NOT NULL
GROUP BY 
    DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)),
    DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)),
    o.DELIVERY_STATUS
ORDER BY Order_Year, Order_Month, o.DELIVERY_STATUS;

--Q28. Month-on-month growth in OrderCount and Revenue (from Nov’15 to July’16)  - 4 Marks
WITH MonthlyData AS (
    SELECT 
        DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Year,
        DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Month,
        COUNT(*) AS Order_Count,
        SUM(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10, 2))) AS Total_Revenue
    FROM 
        orders o
    WHERE 
        TRY_CAST(o.ORDER_DATE AS DATE) IS NOT NULL
        AND TRY_CAST(o.ORDER_DATE AS DATE) BETWEEN '2015-11-01' AND '2016-07-31'
    GROUP BY 
        DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)),
        DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE))
),
Growth AS (
    SELECT 
        Order_Year,
        Order_Month,
        Order_Count,
        Total_Revenue,
        LAG(Order_Count) OVER (ORDER BY Order_Year, Order_Month) AS Prev_Order_Count,
        LAG(Total_Revenue) OVER (ORDER BY Order_Year, Order_Month) AS Prev_Revenue
    FROM 
        MonthlyData
)
SELECT 
    Order_Year,
    Order_Month,
    Order_Count,
    Total_Revenue,
    CASE 
        WHEN Prev_Order_Count IS NULL THEN NULL
        ELSE ((Order_Count - Prev_Order_Count) * 100.0 / Prev_Order_Count)
    END AS Order_Count_Growth_Percent,
    CASE 
        WHEN Prev_Revenue IS NULL THEN NULL
        ELSE ((Total_Revenue - Prev_Revenue) * 100.0 / Prev_Revenue)
    END AS Revenue_Growth_Percent
FROM 
    Growth
ORDER BY 
    Order_Year,
    Order_Month;




--Q29. Month-wise split of total order value of the top 50 customers (The top 50 customers need to identified based on their total order value)  - 6 Marks
WITH TopCustomers AS (
    SELECT 
        CUSTOMER_KEY,
        SUM(TRY_CAST(ORDER_TOTAL AS DECIMAL(10,2))) AS TotalOrderValue
    FROM 
        orders
    GROUP BY 
        CUSTOMER_KEY
    ORDER BY 
        TotalOrderValue DESC
    OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY
),
MonthlyOrderValues AS (
    SELECT 
        DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Year,
        DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Month,
        SUM(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2))) AS TotalOrderValue
    FROM 
        orders o
    JOIN 
        TopCustomers tc ON o.CUSTOMER_KEY = tc.CUSTOMER_KEY
    WHERE
        TRY_CAST(o.ORDER_DATE AS DATE) IS NOT NULL
    GROUP BY 
        DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)),
        DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE))
)

SELECT 
    Order_Year,
    Order_Month,
    TotalOrderValue
FROM 
    MonthlyOrderValues
ORDER BY 
    Order_Year,
    Order_Month;
--Q30. Month-wise split of new and repeat customers. New customers mean, new unique customer additions in any given month  - 6 Marks
WITH FirstPurchase AS (
    SELECT
        CUSTOMER_KEY,
        MIN(DATEPART(YEAR, TRY_CAST(ORDER_DATE AS DATE))) AS First_Purchase_Year,
        MIN(DATEPART(MONTH, TRY_CAST(ORDER_DATE AS DATE))) AS First_Purchase_Month
    FROM 
        orders
    GROUP BY 
        CUSTOMER_KEY
),
CustomerType AS (
    SELECT
        o.CUSTOMER_KEY,
        DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Year,
        DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)) AS Order_Month,
        CASE
            WHEN fp.First_Purchase_Year = DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE))
                 AND fp.First_Purchase_Month = DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE))
            THEN 'New'
            ELSE 'Repeat'
        END AS Customer_Type
    FROM
        orders o
    JOIN
        FirstPurchase fp ON o.CUSTOMER_KEY = fp.CUSTOMER_KEY
)

SELECT 
    Order_Year,
    Order_Month,
    Customer_Type,
    COUNT(DISTINCT CUSTOMER_KEY) AS Number_Of_Customers
FROM 
    CustomerType
GROUP BY 
    Order_Year,
    Order_Month,
    Customer_Type
ORDER BY 
    Order_Year,
    Order_Month,
    Customer_Type;

--Q31. Write stored procedure code which take inputs as location & month, and the output is total_order value and number of orders by Gender, Delivered Status for given location & month. Test the code with different options (12 Marks)
CREATE PROCEDURE GetOrderStats
    @Location NVARCHAR(50),
    @Year INT,
    @Month INT
AS
BEGIN
    SELECT 
        Gender,
        DELIVERY_STATUS,
        SUM(TRY_CAST(ORDER_TOTAL AS DECIMAL(10,2))) AS Total_Order_Value,
        COUNT(*) AS Number_Of_Orders
    FROM 
        orders o
    JOIN 
        customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
    WHERE 
        c.Location = @Location
        AND DATEPART(YEAR, TRY_CAST(o.ORDER_DATE AS DATE)) = @Year
        AND DATEPART(MONTH, TRY_CAST(o.ORDER_DATE AS DATE)) = @Month
    GROUP BY 
        Gender,
        DELIVERY_STATUS
    ORDER BY 
        Gender,
        DELIVERY_STATUS;
END;

EXEC GetOrderStats @Location = 'Chennai', @Year = 2016, @Month = 3;


--Q32. Create Customer 360 File with Below Columns using Orders Data & Customer Data (20 Marks)
/*Customer_ID
CONTACT_NUMBER
Referred Other customers
Gender
Location
Acquired Channel
No.of Orders
Total Order_vallue
Total orders with discount
Total Orders received late
Total Orders returned
Maximum Order value
First Transaction Date
Last Transaction Date
Tenure_Months  (Tenure is defined as the number of months between first & last transaction)
No_of_orders_with_Zero_value*/

WITH Order_Aggregates AS (
    SELECT
        o.CUSTOMER_KEY AS Customer_ID,
        COUNT(o.ORDERS) AS No_of_Orders,
        SUM(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2))) AS Total_Order_Value,
        SUM(CASE 
            WHEN TRY_CAST(o.DISCOUNT AS DECIMAL(10,2)) > 0 THEN 1 
            ELSE 0 
        END) AS Total_Orders_with_Discount,
        SUM(CASE 
            WHEN o.DELIVERY_STATUS = 'LATE' THEN 1 
            ELSE 0 
        END) AS Total_Orders_Received_Late,
        SUM(CASE 
            WHEN o.ORDER_STATUS = 'Cancelled' THEN 1 
            ELSE 0 
        END) AS Total_Orders_Returned,
        MAX(TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2))) AS Maximum_Order_Value,
        MIN(TRY_CAST(o.ORDER_DATE AS DATE)) AS First_Transaction_Date,
        MAX(TRY_CAST(o.ORDER_DATE AS DATE)) AS Last_Transaction_Date,
        SUM(CASE 
            WHEN TRY_CAST(o.ORDER_TOTAL AS DECIMAL(10,2)) = 0 THEN 1 
            ELSE 0 
        END) AS No_of_Orders_with_Zero_Value
    FROM Orders o
    GROUP BY o.CUSTOMER_KEY
),

-- Retrieving customer information
Customer_Info AS (
    SELECT
        c.CUSTOMER_KEY AS Customer_ID,
        c.CONTACT_NUMBER,
        c.[Referred Other Customers] AS Referred_Other_Customers,
        c.Gender,
        c.Location,
        c.[Acquired Channel]
    FROM Customer c
)

-- Joining the aggregated order data with customer information
SELECT
    ci.Customer_ID,
    ci.CONTACT_NUMBER,
    ci.Referred_Other_Customers,
    ci.Gender,
    ci.Location,
    ci.[Acquired Channel],
    oa.No_of_Orders,
    oa.Total_Order_Value,
    oa.Total_Orders_with_Discount,
    oa.Total_Orders_Received_Late,
    oa.Total_Orders_Returned,
    oa.Maximum_Order_Value,
    oa.First_Transaction_Date,
    oa.Last_Transaction_Date,
    DATEDIFF(MONTH, oa.First_Transaction_Date, oa.Last_Transaction_Date) AS Tenure_Months,
    oa.No_of_Orders_with_Zero_Value
FROM Customer_Info ci
JOIN Order_Aggregates oa ON ci.Customer_ID = oa.Customer_ID;
;


--Q33. Total Revenue, total orders by each location ?
SELECT 
    c.Location AS Location,
    COUNT(o.ORDERS) AS Total_Orders,
    SUM(try_cast(o.ORDER_TOTAL as decimal(10,2))) AS Total_Revenue
FROM 
    Orders o
JOIN 
    Customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY 
    c.Location;

--Q34. Total revenue, total orders by customer gender? 
SELECT 
    c.Gender AS Gender,
    COUNT(o.ORDERS) AS Total_Orders,
    SUM(try_cast(o.ORDER_TOTAL as decimal(10,2))) AS Total_Revenue
FROM 
    Orders o
JOIN 
    Customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY 
    c.Gender;
--Q35. Which location of customers cancelling orders maximum? 
SELECT top 1 
    c.Location AS Location,
    COUNT(o.ORDERS) AS Cancelled_Orders
FROM 
    Orders o
JOIN 
    Customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
WHERE 
    o.ORDER_STATUS = 'Cancelled'
GROUP BY 
    c.Location
ORDER BY 
    Cancelled_Orders DESC

--Q36. Total customers, Revenue, Orders by each Acquisition channel (3 Marks)
SELECT 
    c.[Acquired Channel] AS Acquisition_Channel,
    COUNT(DISTINCT c.CUSTOMER_KEY) AS Total_Customers,
    SUM(try_cast(o.ORDER_TOTAL as decimal(10,2))) AS Total_Revenue,
    COUNT(o.ORDERS) AS Total_Orders
FROM 
    Orders o
JOIN 
    Customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY 
    c.[Acquired Channel];

--Q37. Which acquisition channel is good in terms of revenue generation, maximum orders, repeat purchasers? (5 marks)
SELECT 
    c.[Acquired Channel] AS Acquisition_Channel,
    SUM(try_cast(o.ORDER_TOTAL as decimal(10,2))) AS Total_Revenue  
FROM 
    Orders o
JOIN 
    Customer c ON o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY 
    c.[Acquired Channel];
--Q38. Write User Defined Function (stored procedure) which can take input table which create two tables with numerical variables and categorical variables separately (10 Marks)
CREATE PROCEDURE SeparateVariables
    @InputTable NVARCHAR(128) 
AS
BEGIN
    -- Dynamic SQL variables
    DECLARE @Sql NVARCHAR(MAX);
    DECLARE @CreateNumericalTable NVARCHAR(MAX);
    DECLARE @CreateCategoricalTable NVARCHAR(MAX);
    DECLARE @InsertNumericalData NVARCHAR(MAX);
    DECLARE @InsertCategoricalData NVARCHAR(MAX);

    -- Drop existing tables if they exist
    SET @Sql = 'IF OBJECT_ID(''NumericalVariables'', ''U'') IS NOT NULL DROP TABLE NumericalVariables;
                IF OBJECT_ID(''CategoricalVariables'', ''U'') IS NOT NULL DROP TABLE CategoricalVariables;';
    EXEC sp_executesql @Sql;

    -- Create new tables for numerical and categorical variables
    SET @CreateNumericalTable = 'CREATE TABLE NumericalVariables (';
    SET @CreateCategoricalTable = 'CREATE TABLE CategoricalVariables (';

    -- Query to get the columns and their data types
    SET @Sql = 'SELECT COLUMN_NAME, DATA_TYPE
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = @InputTable';
    EXEC sp_executesql @Sql, N'@InputTable NVARCHAR(128)', @InputTable;

    -- Append columns to the CREATE TABLE statements based on their data types
    -- (This needs to be executed dynamically based on the result of the above query)
    -- Example placeholders:
    -- @CreateNumericalTable += 'ColumnName1 NUMERIC(18, 2), '
    -- @CreateCategoricalTable += 'ColumnName2 VARCHAR(255), '

    -- Finalize table creation statements
    SET @CreateNumericalTable += 'PRIMARY KEY (ID));';
    SET @CreateCategoricalTable += 'PRIMARY KEY (ID));';

    -- Execute the CREATE TABLE statements
    EXEC sp_executesql @CreateNumericalTable;
    EXEC sp_executesql @CreateCategoricalTable;

    -- Insert data into the NumericalVariables table
    SET @InsertNumericalData = 'INSERT INTO NumericalVariables (SELECT * FROM ' + @InputTable + ' WHERE ' + '/* Conditions to filter numerical columns */' + ');';
    EXEC sp_executesql @InsertNumericalData;

    -- Insert data into the CategoricalVariables table
    SET @InsertCategoricalData = 'INSERT INTO CategoricalVariables (SELECT * FROM ' + @InputTable + ' WHERE ' + '/* Conditions to filter categorical columns */' + ');';
    EXEC sp_executesql @InsertCategoricalData;
END;
--Q39. Prepare at least 5 additional analysis on your own?
--1. Monthly Revenue Trends
SELECT
    YEAR(TRY_CAST(ORDER_DATE AS DATE)) AS Year,
    MONTH(TRY_CAST(ORDER_DATE AS DATE)) AS Month,
    SUM(TRY_CAST(ORDER_TOTAL AS DECIMAL(10, 2))) AS TotalRevenue
FROM Orders
WHERE TRY_CAST(ORDER_DATE AS DATE) IS NOT NULL
GROUP BY YEAR(TRY_CAST(ORDER_DATE AS DATE)), MONTH(TRY_CAST(ORDER_DATE AS DATE))
ORDER BY Year, Month desc;
--2. Customer Lifetime Value 
SELECT
    C.CUSTOMER_KEY,
    C.Gender,
    C.Location,
    SUM(try_cast(O.ORDER_TOTAL as decimal(10,2))) AS LifetimeValue
FROM
    Orders O
JOIN
    Customer C ON O.CUSTOMER_KEY = C.CUSTOMER_KEY
GROUP BY
    C.CUSTOMER_KEY,
    C.Gender,
    C.Location
ORDER BY
    LifetimeValue DESC;
--3. Order Status Distribution by Location
SELECT
    C.Location,
    O.ORDER_STATUS,
    COUNT(*) AS OrderCount
FROM
    Orders O
JOIN
    Customer C ON O.CUSTOMER_KEY = C.CUSTOMER_KEY
GROUP BY
    C.Location,
    O.ORDER_STATUS
ORDER BY
    C.Location,
    O.ORDER_STATUS;
--4. Average Order Value by Acquisition Channel
SELECT
    C.[Acquired Channel],
    AVG(try_cast(O.ORDER_TOTAL as decimal(10,2))) AS AverageOrderValue
FROM
    Orders O
JOIN
    Customer C ON O.CUSTOMER_KEY = C.CUSTOMER_KEY
GROUP BY
    C.[Acquired Channel]
ORDER BY
    AverageOrderValue DESC;
--5. Repeat Purchase Rate by Customer
WITH CustomerOrders AS (
    SELECT
        CUSTOMER_KEY,
        COUNT(*) AS OrderCount
    FROM
        Orders
    GROUP BY
        CUSTOMER_KEY
)
SELECT
    C.CUSTOMER_KEY,
    C.Gender,
    C.Location,
    COALESCE(CAST(O.OrderCount AS FLOAT) / NULLIF((SELECT COUNT(*) FROM Orders), 0), 0) AS RepeatPurchaseRate
FROM
    CustomerOrders O
JOIN
    Customer C ON O.CUSTOMER_KEY = C.CUSTOMER_KEY
WHERE
    O.OrderCount > 1
ORDER BY
    RepeatPurchaseRate DESC;










