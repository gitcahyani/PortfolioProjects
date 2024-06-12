--Q1. Overall ROMI
SELECT round((sum(revenue) - sum(mark_spent)) / sum(mark_spent),2) as overall_ROMI FROM Marketing

--Q2. ROMI by Campaigns
SELECT 
	campaign_id,
	campaign_name,
	round((sum(revenue) - sum(mark_spent)) / sum(mark_spent),2) as ROMI
FROM Marketing
GROUP BY campaign_id, campaign_name

--Q3. Performance of the campaign depending on the date:
--on which date did we spend the most money on advertising? 2021-02-20
SELECT
	c_date,
	sum(mark_spent) as mkt_cost,
	sum(revenue) as revenue
FROM Marketing
group by c_date
order by sum(mark_spent) desc

--when we got the biggest revenue? 2021-02-20
SELECT
	c_date,
	sum(mark_spent) as mkt_cost,
	sum(revenue) as revenue
FROM Marketing
group by c_date
order by sum(revenue) desc

--when conversion rates (leads to order conversion) were high and low?
--the highest leads to order rate conversion is on 2021-02-25 by 0.015
SELECT TOP 1
	c_date,
	sum(orders)*0.1 / sum(leads) as leads_to_order
FROM Marketing
GROUP BY c_date
ORDER BY 2 DESC

--and the lowest leads to order rate conversion is on 2021-02-18 by 0.009
SELECT TOP 1
	c_date,
	sum(orders)*0.1 / sum(leads) as leads_to_order
FROM Marketing
GROUP BY c_date
ORDER BY 2 ASC

--Q4. What were the average order values? INR 53325
SELECT
	sum(revenue)/sum(orders) as AOV
FROM Marketing

--Q5. When buyers are more active? What is the average revenue on weekdays and weekends?
-- Buyers shops more on the weekends
WITH table_mkt AS(
SELECT
	*,
	--DATENAME(dw, c_date) as c_day,
	CASE 
		WHEN DATENAME(dw, c_date)='Saturday' OR DATENAME(dw, c_date)='Sunday' THEN 'weekends' 
		ELSE 'weekdays'
	END AS week_cat
FROM Marketing
)
SELECT
	week_cat,
	sum(revenue)/sum(orders) as AOV
from table_mkt
GROUP BY week_cat

--Q6. Which types of campaigns work best - social, banner, influencer, or a search?
--Influencer campaigns have the highest ROMI. Therefore it works the best.
SELECT
	category,
	ROUND((SUM(revenue) - SUM(mark_spent)) / SUM(mark_spent),2) as ROMI,
	sum(revenue) as revenue
FROM Marketing
GROUP BY category
ORDER BY 2 DESC

--Q7. Which geo locations are better for targeting - tier 1 or tier 2 cities?
-- Tier1 is better for targeting as it has higher leads to irder conversion rate
-- While Tier2 is suitable for re-targeting because it has a higher impression to clicks rate, but have not yet place an order
WITH table_mkt AS(
SELECT
	*,
	CASE 
		WHEN campaign_name LIKE '%tier1%' THEN 'Tier1'
		WHEN campaign_name LIKE '%tier2%' THEN 'Tier2'
	END AS tier_cat
FROM Marketing
)
SELECT
	tier_cat,
	sum(clicks)*0.1 / sum(impressions) as imp_to_clicks,
	sum(leads)*0.1 / sum(clicks) as clicks_to_leads,
	sum(orders)*0.1 / sum(leads) as leads_to_order
from table_mkt
WHERE tier_cat IS NOT NULL
group by tier_cat

--Q8. ROMI, Cost per Click, Cost per Lead by Category
SELECT
	category,
	round((sum(revenue) - sum(mark_spent)) / sum(mark_spent),2) as ROMI,
	round(sum(mark_spent)*0.1 / sum(clicks),2) as CPC,
	round(sum(mark_spent)*0.1 / sum(leads),2) as CPL
FROM Marketing
GROUP BY category

--Q9. List all the worst performing campaign_id (negative margin)
SELECT
	campaign_id,
	revenue - mark_spent AS margin
FROM Marketing
WHERE revenue - mark_spent < 0
ORDER BY 2 ASC

--Q10. List top 10 best performing campaign_id (positive margin)
SELECT TOP 10
	campaign_id,
	revenue - mark_spent AS margin
FROM Marketing
WHERE revenue - mark_spent > 0
ORDER BY 3 DESC

--Q11. Which platform has the highest ROMI
--Youtube have the highest ROMI while Facebook is the lowest
WITH table_mkt AS(
SELECT
	*,
	CASE 
		WHEN LOWER(campaign_name) LIKE '%facebook%' THEN 'Facebook'
		WHEN LOWER(campaign_name) LIKE '%instagram%' THEN 'Instagram'
		WHEN LOWER(campaign_name) LIKE '%youtube%' THEN 'Youtube'
		WHEN LOWER(campaign_name) LIKE '%google%' THEN 'Google'
		ELSE campaign_name
	END AS platform_name
FROM Marketing
)
SELECT
	platform_name,
	round((sum(revenue) - sum(mark_spent)) / sum(mark_spent),2) as ROMI
from table_mkt
group by platform_name
order by 2 desc

--Q12. Show all the performance based on category
-- Influencer have best performance overall
SELECT
	category,
	sum(clicks)*0.1 / sum(impressions) as imp_to_clicks,
	sum(leads)*0.1 / sum(clicks) as clicks_to_leads,
	sum(orders)*0.1 / sum(leads) as leads_to_order,
	round((sum(revenue) - sum(mark_spent)) / sum(mark_spent),2) as ROMI
FROM Marketing
GROUP BY category
ORDER BY 5 DESC
group by tier_cat