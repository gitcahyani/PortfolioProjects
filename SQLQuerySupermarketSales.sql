--Supermarket Sales

--checking the overall table
SELECT * from Sales

--check for Invoice_ID duplicates
--result: no Invoice_ID duplicates
SELECT 
	COUNT(Invoice_ID) as count_all,
	COUNT(DISTINCT Invoice_ID) as count_unique
FROM Sales

--sales, cogs, gross_margin_percentage, gross_income
--result:	gross_margin_percentage cannot be used because it has the same value for all  rows
--		cogs looks like it represents cogs per unit, create all_cogs for cogs * Quantity
--		data in gross_income also cannot be used because the calculation is incorrect
--		create new column margin for margin calculation: Total - all_cogs / Total
--		data in new column margin is still incorrect, because it has over thousands %
--		probably because data in cogs is not correct, therefore i'm going to drop analysis using cogs & margin
SELECT 
	Quantity,
	Total,
	cogs,
	cogs*Quantity as all_cogs,
	gross_margin_percentage,
	Total - cogs*Quantity / Total * 100.0 as margin,
	gross_income
from Sales

--check the min and max date in this table
--result:	period is Q1 2019
SELECT
	MIN(Date) as start_date,
	MAX(Date) as end_date
FROM Sales

--SALES PERFORMANCE
--total sales per branch & city
--result:	Branch C Naypyitaw lead the Q1 2019 sales by 34%,
--		followed by Branch B Mandalay and Branch A Yangon by 33% and 32%, respectively
SELECT
	Branch,
	City,
	SUM(Total) as total_sales,
	SUM(Total) * 100.0 / (SELECT SUM(Total) FROM Sales) as perc_sales
FROM Sales
GROUP BY Branch, City
ORDER BY 3 DESC

--show total sales monthly
--result: Jan-19 has the highest sales performance, 
--	  and then dropped by 25%% in Feb-19, and slightly dipped by 0.3% in Mar-19
SELECT
	CASE
		WHEN Date BETWEEN '2019-01-01' AND '2019-01-31' THEN '01. January 2019'
		WHEN Date BETWEEN '2019-02-01' AND '2019-02-28' THEN '02. February 2019'
		WHEN Date BETWEEN '2019-03-01' AND '2019-03-31' THEN '03. March 2019'
	END as month_tx,
	SUM(Total) as total_sales
FROM Sales
GROUP BY
	CASE
		WHEN Date BETWEEN '2019-01-01' AND '2019-01-31' THEN '01. January 2019'
		WHEN Date BETWEEN '2019-02-01' AND '2019-02-28' THEN '02. February 2019'
		WHEN Date BETWEEN '2019-03-01' AND '2019-03-31' THEN '03. March 2019'
	END
ORDER BY 1

--show total sales & city monthly
SELECT
	CASE
		WHEN Date BETWEEN '2019-01-01' AND '2019-01-31' THEN '01. January 2019'
		WHEN Date BETWEEN '2019-02-01' AND '2019-02-28' THEN '02. February 2019'
		WHEN Date BETWEEN '2019-03-01' AND '2019-03-31' THEN '03. March 2019'
	END as month_tx,
	City,
	SUM(Total) as total_sales
FROM Sales
GROUP BY
	CASE
		WHEN Date BETWEEN '2019-01-01' AND '2019-01-31' THEN '01. January 2019'
		WHEN Date BETWEEN '2019-02-01' AND '2019-02-28' THEN '02. February 2019'
		WHEN Date BETWEEN '2019-03-01' AND '2019-03-31' THEN '03. March 2019'
	END,
	City
ORDER BY 1,2

--total sales based on product_line
--result: top selling product line (based on total sales value) is health & beauty
SELECT
	Product_line,
	SUM(Total) as total_sales
FROM Sales
GROUP BY Product_line
ORDER BY 2 DESC

--total sales based on gender
--result: Female customers contribute higher spending than Male by 54%
SELECT
	Gender,
	SUM(Total) as total_sales,
	SUM(Total) * 100.0/(SELECT SUM(Total) FROM Sales) as perc_sales
FROM Sales
GROUP BY Gender
ORDER BY 2 DESC

--total sales based on customer_type
--result: Female Member is the highest spending customer category
SELECT
	Customer_type,
	Gender,
	SUM(Total) as total_sales,
	SUM(Total) * 100.0/(SELECT SUM(Total) FROM Sales) as perc_sales
FROM Sales
GROUP BY Customer_type, Gender
ORDER BY 1, 2 DESC

--sales based on payment
--result: relatively equal distribution between payment with cash (35%), ewallet(33%) & credit card(30%)
SELECT
	Payment,
	SUM(Total) as total_sales,
	SUM(Total) * 100.0/(SELECT SUM(Total) FROM Sales) as perc_sales
FROM Sales
GROUP BY Payment
ORDER BY 2 DESC

--CUSTOMER BEHAVIOUR

--customer satisfaction based on rating given 
--i will define 3 range: 0 - 60 bad experience
--			61 - 80 okay experience
--			81 - 100 excellent experience
--checking the min, max, and avg rating value
SELECT
	MIN(Rating) as min_rating,
	MAX(Rating) as max_rating,
	AVG(Rating) as avg_rating
FROM Sales

--first let's make the rating group
SELECT
	CASE
		WHEN Rating BETWEEN 0 AND 60 THEN 'Bad Experience'
		WHEN Rating BETWEEN 61 AND 80 THEN 'OK Experience'
		ELSE 'Excellent Experience'
	END as rating_group,
	COUNT(*) as num_rating
FROM Sales
GROUP BY 
	CASE
		WHEN Rating BETWEEN 0 AND 60 THEN 'Bad Experience'
		WHEN Rating BETWEEN 61 AND 80 THEN 'OK Experience'
		ELSE 'Excellent Experience'
	END

--let's take a closer look on the Bad Experience, which branch/city have the most bad experience rating?
--result: Branch Mandalay has the highest bad rating
SELECT
	City,
	COUNT(*) as num_bad_rating,
	COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Sales WHERE Rating < 60) as perc_bad_rating
FROM Sales
WHERE Rating < 60
GROUP BY City
ORDER BY 2 DESC

-- when is the busiest time in the supermarket?
-- create 3 time group:	Morning < 12:00:00
--			Noon > 12:00:00 AND < 18:00:00
--			Night > 18:00:00
-- result: Noon is the busiest time
SELECT
	CASE
		WHEN Time < '12:00:00' THEN 'Morning'
		WHEN Time > '12:00:00' AND Time < '18:00:00' THEN 'Noon'
		ELSE 'Night'
	END as time_group,
	COUNT(*) as num_transaction,
	COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Sales)
from Sales
GROUP BY
	CASE
		WHEN Time < '12:00:00' THEN 'Morning'
		WHEN Time > '12:00:00' AND Time < '18:00:00' THEN 'Noon'
		ELSE 'Night'
	END
ORDER BY 1 DESC

--Let's say there is an ongoing lucky draw for the top 3 spenders Q1 2019 within single transaction 
--Find the Invoice_ID list that met this criteria
SELECT *
FROM(
	SELECT
		City,
		Invoice_ID,
		SUM(Total) as total_spend,
		ROW_NUMBER() OVER (PARTITION BY City ORDER BY SUM(Total) DESC) as spend_rank
	FROM Sales
	GROUP BY City,
		Invoice_ID
	) as top_spenders
WHERE spend_rank <= 3
ORDER BY City, spend_rank

