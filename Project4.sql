--Investigation
SELECT * FROM Project4..larger_sales;
SELECT COUNT(*) FROM Project4..larger_sales;


--DATA EXPLORATION
SELECT AVG(Quantity) AS AVG_Order_Qty, 
		ROUND(AVG(Unit_Price), 2) AS AVG_Price, 
		ROUND(AVG(Total_Price), 2) AS AVG_Total_Price
FROM Project4..larger_sales;--Average

SELECT Order_Status, COUNT(*) AS Total_Orders
FROM Project4..larger_sales
GROUP BY Order_Status;--Total Orders per Order_Status

SELECT Product_Category, Order_Status,
SUM(Quantity) AS Total_Items_Ordered, 
ROUND(SUM(Total_Price), 2) AS Total_Value
FROM Project4..larger_sales
GROUP BY Product_Category, Order_Status
ORDER BY Product_Category, Order_Status, Total_Items_Ordered DESC;--Total items of Order Status per Product_Category

WITH daily_changes AS (
  SELECT Order_Date,
    SUM(CASE 
        WHEN Order_Status = 'Completed' THEN Total_Price
        --WHEN Order_Status = 'Pending' THEN Total_Price
        --WHEN Order_Status = 'Refunded' THEN -Total_Price
        --WHEN Order_Status = 'Cancelled' THEN -Total_Price
        ELSE 0
      END) AS status_change
  FROM Project4..larger_sales
  GROUP BY Order_Date)
SELECT Order_Date,
		ROUND(SUM(status_change) OVER (ORDER BY Order_Date), 2) AS Cumulative_Change
FROM daily_changes
ORDER BY Order_Date DESC;--Cumulative Change of Completed Orders


--DESCRIPTIVE ANALYSIS

		--Summary Statistics
SELECT  AVG(Quantity) AS Qty_Mean, 
		AVG(Unit_Price) AS UP_Mean, 
		AVG(Total_Price) AS TP_Mean 
FROM Project4..larger_sales;--Mean

SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Quantity) OVER() AS Qty_Median,
				PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Unit_Price) OVER() AS UP_Median,
				PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Total_Price) OVER() AS TP_Median
FROM Project4..larger_sales;--Median

SELECT Quantity AS Qty_Mode
FROM ( SELECT Quantity, RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk 
    FROM Project4..larger_sales
    GROUP BY Quantity) AS ranked
WHERE rnk = 1;--Qty_Mode

SELECT STDEV(Quantity) AS Qty_std, 
		STDEV(Unit_Price) AS UP_std, 
		STDEV(Total_Price) AS TP_std 
FROM Project4..larger_sales;--Standard deviation

WITH 
stats AS (
  SELECT
    AVG(Quantity) AS Mean, STDEV(Quantity) AS ST_Deviation
  FROM Project4..larger_sales),
median_cte AS ( SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Quantity) OVER () AS Median
  FROM Project4..larger_sales),
mode_cte AS ( SELECT
    Quantity AS Mode,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
  FROM Project4..larger_sales
  GROUP BY Quantity)
SELECT DISTINCT Mean, ST_Deviation, Median,
  (SELECT Mode FROM mode_cte WHERE rnk = 1) AS Mode
FROM stats, median_cte;-- Quantity Summary Statistics


		--Product Analysis
SELECT Product_Category, 
		SUM(Quantity) AS Total_Items_Ordered,
		SUM(Total_Price) AS Total_Price
FROM Project4..larger_sales
GROUP BY Product_Category
ORDER BY Total_Items_Ordered DESC;--Total Items per Category
SELECT Product_Category, 
		COUNT(*) AS Total_Orders,
		SUM(Total_Price) AS Total_Value
FROM Project4..larger_sales
GROUP BY Product_Category
ORDER BY Total_Orders DESC;--Total Orders per Category

SELECT Product_Category, 
		SUM(Quantity) AS Total_Items_Ordered,
		SUM(Total_Price) AS Total_Value
FROM Project4..larger_sales
WHERE Order_Status = 'Completed'
GROUP BY Product_Category
ORDER BY Total_Items_Ordered DESC;--Total sold products per category(Completed Order Status)
SELECT Product_Category, 
		SUM(Quantity) AS Total_Items_Ordered,
		SUM(Total_Price) AS Total_Value
FROM Project4..larger_sales
WHERE Order_Status = 'Pending'
GROUP BY Product_Category
ORDER BY Total_Items_Ordered DESC;--Total Pending Orders per category
SELECT Product_Category, 
		SUM(Quantity) AS Total_Items_Ordered,
		SUM(Total_Price) AS Total_Value
FROM Project4..larger_sales
WHERE Order_Status = 'Cancelled'
GROUP BY Product_Category
ORDER BY Total_Items_Ordered DESC;--Total Cancelled Orders per category
SELECT Product_Category, 
		SUM(Quantity) AS Total_Items_Ordered,
		SUM(Total_Price) AS Total_Value
FROM Project4..larger_sales
WHERE Order_Status = 'Refunded'
GROUP BY Product_Category
ORDER BY Total_Items_Ordered DESC;--Total Refunded Orders per category

		--Time Analysis
SELECT DATENAME(MONTH, Order_Date) AS Month, 
		Product_Category,
		SUM(Quantity) AS Total_Sold_Items
FROM Project4..larger_sales
WHERE Order_Status = 'Completed'
GROUP BY DATENAME(MONTH, Order_Date),DATEPART(MONTH, Order_Date), Product_Category
ORDER BY DATEPART(MONTH, Order_Date), Total_Sold_Items DESC;--Monthly Items Sold by category

SELECT DATENAME(MONTH, Order_Date) AS Month, 
		Product_Category,
		SUM(Quantity) AS Total_Pending_Orders
FROM Project4..larger_sales
WHERE Order_Status = 'Pending'
GROUP BY DATENAME(MONTH, Order_Date),DATEPART(MONTH, Order_Date), Product_Category
ORDER BY DATEPART(MONTH, Order_Date), Total_Pending_Orders DESC;--Monthly Pending Items by Category

SELECT DATENAME(MONTH, Order_Date) AS Month, 
		Product_Category,
		SUM(Quantity) AS Total_Cancelled_Orders
FROM Project4..larger_sales
WHERE Order_Status = 'Cancelled'
GROUP BY DATENAME(MONTH, Order_Date),DATEPART(MONTH, Order_Date), Product_Category
ORDER BY DATEPART(MONTH, Order_Date), Total_Cancelled_Orders DESC;--Monthly Cancelled Items by Category

SELECT DATENAME(MONTH, Order_Date) AS Month, 
		Product_Category,
		SUM(Quantity) AS Total_Refunded_Orders
FROM Project4..larger_sales
WHERE Order_Status = 'Refunded'
GROUP BY DATENAME(MONTH, Order_Date),DATEPART(MONTH, Order_Date), Product_Category
ORDER BY DATEPART(MONTH, Order_Date), Total_Refunded_Orders DESC;--Monthly Refunded Items by Category

--PERFORMANCE METRICS

		--Revenue Analysis
SELECT DATENAME(MONTH, Order_Date) AS Month, Product_Category,
		SUM(Quantity) AS Total_Sold_Items, ROUND(SUM(Total_Price), 2) AS Revenue
FROM Project4..larger_sales
WHERE Order_Status = 'Completed'
GROUP BY DATENAME(MONTH, Order_Date),DATEPART(MONTH, Order_Date), Product_Category
ORDER BY DATEPART(MONTH, Order_Date), Revenue DESC;--Total completed orders by month

SELECT DATENAME(MONTH, Order_Date) AS Month, Product_Category,
		SUM(Quantity) AS Total_Pending_Orders, ROUND(SUM(Total_Price), 2) AS Total_Value
FROM Project4..larger_sales
WHERE Order_Status = 'Pending'
GROUP BY DATENAME(MONTH, Order_Date),DATEPART(MONTH, Order_Date), Product_Category
ORDER BY DATEPART(MONTH, Order_Date), Total_Value DESC;--Total Pending orders by month

SELECT DATENAME(MONTH, Order_Date) AS Month, Product_Category,
		SUM(Quantity) AS Total_Cancelled_Orders, ROUND(SUM(Total_Price), 2) AS Total_Value
FROM Project4..larger_sales
WHERE Order_Status = 'Cancelled'
GROUP BY DATENAME(MONTH, Order_Date),DATEPART(MONTH, Order_Date), Product_Category
ORDER BY DATEPART(MONTH, Order_Date), Total_Value DESC;--Total cancelled orders by month

SELECT DATENAME(MONTH, Order_Date) AS Month, Product_Category,
		SUM(Quantity) AS Total_Refunded_Orders, ROUND(SUM(Total_Price), 2) AS Total_Value
FROM Project4..larger_sales
WHERE Order_Status = 'Refunded'
GROUP BY DATENAME(MONTH, Order_Date),DATEPART(MONTH, Order_Date), Product_Category
ORDER BY DATEPART(MONTH, Order_Date), Total_Value DESC;--Total refunded orders by month


--VISUALIZATION
		--Sales Trends

		--Product Performance
SELECT Product_Category, Order_Status,
SUM(Quantity) AS Total_Items_Ordered, 
ROUND(SUM(Total_Price), 2) AS Total_Value
FROM Project4..larger_sales
GROUP BY Product_Category, Order_Status
ORDER BY Product_Category, Order_Status;--Total items from Product Category per Order Status

		--Payment Analysis
SELECT Payment_Type, 
		COUNT(*) AS Total_Payments,
		ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM Project4..larger_sales WHERE Order_Status = 'Completed') * 100, 2) AS Payment_Percentage
FROM Project4..larger_sales 
WHERE Order_Status = 'Completed'
GROUP BY Payment_Type 
ORDER BY COUNT(*) DESC;--Total Completed Orders per payment type
SELECT Payment_Type, 
		COUNT(*) AS Total_Payments,
		ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM Project4..larger_sales WHERE Order_Status = 'Pending') * 100, 2) AS Payment_Percentage
FROM Project4..larger_sales 
WHERE Order_Status = 'Pending'
GROUP BY Payment_Type 
ORDER BY COUNT(*) DESC;--Total Pending Orders per payment type
SELECT Payment_Type, 
		COUNT(*) AS Total_Payments,
		ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM Project4..larger_sales WHERE Order_Status = 'Cancelled') * 100, 2) AS Payment_Percentage
FROM Project4..larger_sales 
WHERE Order_Status = 'Cancelled'
GROUP BY Payment_Type 
ORDER BY COUNT(*) DESC;--Total Cancelled Orders per payment type
SELECT Payment_Type, 
		COUNT(*) AS Total_Payments,
		ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM Project4..larger_sales WHERE Order_Status = 'Refunded') * 100, 2) AS Payment_Percentage
FROM Project4..larger_sales 
WHERE Order_Status = 'Refunded'
GROUP BY Payment_Type 
ORDER BY COUNT(*) DESC;--Total Refunded Orders per payment type

SELECT Payment_Type, 
		COUNT(*) AS Total_Payments,
		ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM Project4..larger_sales) * 100, 2) AS Payment_Percentage
FROM Project4..larger_sales 
GROUP BY Payment_Type 
ORDER BY COUNT(*) DESC;--Total Orders per Payment_Type
WITH monthly_totals AS (
    SELECT 
        DATENAME(MONTH, Order_Date) AS Month,
        DATEPART(MONTH, Order_Date) AS Month_Number,
        Payment_Type,
        COUNT(*) AS Total_Orders,
        SUM(COUNT(*)) OVER (PARTITION BY DATEPART(MONTH, Order_Date)) AS Total_Orders_Month
    FROM Project4..larger_sales
    -- WHERE Order_Status = 'Completed' (Use this as a filter)
    GROUP BY DATENAME(MONTH, Order_Date), DATEPART(MONTH, Order_Date), Payment_Type)
SELECT Month,
    Payment_Type,
    Total_Orders,
    ROUND(CAST(Total_Orders AS FLOAT) / Total_Orders_Month * 100, 2) AS Monthly_Payment_Percentage
FROM monthly_totals
ORDER BY Month_Number, Payment_Type;--Monthly orders per payment type


--ADVANCE ANALYSIS
		--Correlation Analysis
WITH summary_stats AS (
    SELECT COUNT(*) AS n,
			SUM(Quantity) AS sum_Qty,
			SUM(Unit_Price) AS sum_UP,
			SUM(Total_Price) AS sum_TP,
			SUM(Quantity * Quantity) AS sum_Qty_squared,
			SUM(Unit_Price * Unit_Price) AS sum_UP_squared,
			SUM(Total_Price * Total_Price) AS sum_TP_squared,
			SUM(Quantity * Unit_Price) AS sum_Qty_UP,
			SUM(Quantity * Total_Price) AS sum_Qty_TP,
			SUM(Unit_Price * Total_Price) AS sum_UP_TP
    FROM Project4..larger_sales
	WHERE Order_Status = 'Completed'),
correlation AS (
    SELECT (n * sum_Qty_UP - sum_Qty * sum_UP) /
			SQRT((n * sum_Qty_squared - sum_Qty * sum_Qty) * 
				 (n * sum_UP_squared - sum_UP * sum_UP)) AS correlation_Qty_UP,
			(n * sum_Qty_TP - sum_Qty * sum_TP) /
			SQRT((n * sum_Qty_squared - sum_Qty * sum_Qty) * 
				 (n * sum_TP_squared - sum_TP * sum_TP)) AS correlation_Qty_TP,
			(n * sum_UP_TP - sum_UP * sum_TP) /
			SQRT((n * sum_UP_squared - sum_UP * sum_UP) * 
				 (n * sum_TP_squared - sum_TP * sum_TP)) AS correlation_UP_TP
    FROM summary_stats)
SELECT correlation_Qty_UP AS correlation_Quantity_Unit_Price,
		correlation_Qty_TP AS correlation_Quantity_Total_Price,
		correlation_UP_TP AS correlation_Unit_Price_Total_Price
FROM correlation;--Correlation between Quantity, Unit_Price, and Total_Price of Completed Orders
		

--ACTIONABLE INSIGHTS
		--Identify Opportunities

		--Optimize Pricing Strategies

		--Enhance Marketing Efforts


--REPORTING
		--Create Dashboard

		--Document Insights