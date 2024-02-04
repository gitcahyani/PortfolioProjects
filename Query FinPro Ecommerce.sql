SELECT * FROM finpro_ecommerce.order_detail;

-- Q1. Which month have the highest after_discount values in 2021?
-- Answer: August 2021
select
	extract(month from order_date) as mth,
    	round(sum(after_discount),2) as total_order
from
	order_detail
where is_valid = 1
	and extract(year from order_date) = 2021
group by 1
order by 2 desc;

-- Q2. During 2022, what category contributes the highest after_discount value?
-- Answer: Mobile & Tablets
select
	s.category,
    	round(SUM(o.after_discount),2) as total_sales
from order_detail o
left join sku_detail s on o.sku_id = s.id
where is_valid = 1
	and extract(year from order_date) = 2022
group by 1
order by 2 desc
;

-- Q3. Compare transaction value from 2021 vs 2022 based on category
-- Which category that have + growth and - growth?
select
	category,
    	sales_2022,
    	sales_2021,
    	case
		when sales_2022>sales_2021 then 'positive growth'
        	else 'negative growth'
    	end as remarks
from
	(select
		s.category,
		round(sum(case when year(o.order_date)=2021 then after_discount else 0 end),2) as sales_2021,
		round(sum(case when year(o.order_date)=2022 then after_discount else 0 end),2) as sales_2022
	from
		order_detail o
	left join sku_detail s on o.sku_id = s.id
	where is_valid = 1
		and year(o.order_date) in (2021,2022)
	group by 1) as pivot_tab
;

-- Q4. Show top 5 payment methods in 2022 (based on total unique order)
-- Answer: COD is the most popular, the rest 4 see the result table
select
    p.payment_method,
    count(distinct o.id) as count_order
from order_detail o
	left join payment_detail p on o.payment_id = p.id
where o.is_valid = 1
	and year(o.order_date) = 2022
group by 1
order by 2 desc
limit 5;

-- Q5. Sort these 5 products based on their transaction values
-- Samsung, Apple, Sony, Huawei, Lenovo
with
	table_product as (
    select
		o.id,
		s.sku_name,
        	o.after_discount,
		case
			when lower(s.sku_name) like '%samsung%' then 'Samsung'
            		when lower(s.sku_name) like '%sony%' then 'Sony'
            		when lower(s.sku_name) like '%huawei%' then 'Huawei'
            		when lower(s.sku_name) like '%lenovo%' then 'Lenovo'
			when lower(s.sku_name) like '%apple%' then 'Apple'
			when lower(s.sku_name) like '%iphone%' then 'Apple'
			when lower(s.sku_name) like '%macbook%' then 'Apple'
			when lower(s.sku_name) like '%ipad%' then 'Apple'
		end as brand_tag
    from order_detail o
		left join sku_detail s on o.sku_id = s.id
    where is_valid = 1
    )

select
	brand_tag,
    	round(sum(after_discount),2) as total_sales
from table_product
where brand_tag is not null
group by 1
order by 2 desc


