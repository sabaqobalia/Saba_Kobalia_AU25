--task 1
WITH cxr AS (
SELECT c.cust_id,cust_last_name,cust_first_name, ch.channel_desc, SUM(amount_sold) AS customer_sales,
SUM(SUM(amount_sold)) OVER (PARTITION BY ch.channel_desc) as channel_total
FROM sh.sales s
LEFT JOIN sh.customers c ON c.cust_id=s.cust_id
LEFT JOIN sh.channels ch ON ch.channel_id=s.channel_id
GROUP BY c.cust_id,cust_last_name,cust_first_name,ch.channel_desc
),
cxr2 AS (
SELECT cust_id,cust_last_name,cust_first_name,channel_desc,customer_sales,channel_total,
RANK () OVER (PARTITION BY channel_desc ORDER BY customer_sales DESC NULLS LAST) AS channel_rank,
ROUND (customer_sales * 100/channel_total,4)||'%' AS sales_percentage

FROM cxr
)

SELECT channel_desc,cust_last_name,cust_first_name,customer_sales AS amount_sold,channel_rank,sales_percentage
FROM cxr2	
WHERE channel_rank <6
ORDER BY channel_desc, channel_rank;

--task 2
--i'm writing this on deadline day and couldn't figure out how to solve using window functions, sorry!
WITH cxr AS (

SELECT p.prod_name,  amount_sold,time_id
FROM sh.sales s LEFT JOIN sh.products p ON s.prod_id=p.prod_id
LEFT JOIN sh.customers cu ON cu.cust_id=s.cust_id
LEFT JOIN sh.countries co ON cu.country_id=co.country_id
WHERE EXTRACT (YEAR FROM time_id)=2000 AND
country_subregion='Asia' AND
p.prod_category = 'Photo'
)


SELECT prod_name,
ROUND (SUM (CASE WHEN EXTRACT (quarter FROM time_id) =1 THEN amount_sold ELSE 0 END ),2) AS q1,
ROUND (SUM (CASE WHEN EXTRACT (quarter FROM time_id) =2 THEN amount_sold ELSE 0 END ),2) AS q2,
ROUND (SUM (CASE WHEN EXTRACT (quarter FROM time_id) =3 THEN amount_sold ELSE 0 END ),2) AS q3,
ROUND (SUM (CASE WHEN EXTRACT (quarter FROM time_id) =4 THEN amount_sold ELSE 0 END ),2) AS q4,
ROUND (SUM (amount_sold),2) AS YEAR_SUM
FROM cxr
GROUP BY prod_name;

-- task 3
--task description on learn.epam was very ambigous, but the output matches the sample one provided, so i think i got it.
GROUP BY channel_desc, s.cust_id, cust_last_name,cust_first_name)
),
top300_99 AS (
SELECT  channel_desc, cust_id, cust_last_name,cust_first_name,cust_channel_total,
RANK () OVER (PARTITION BY channel_desc ORDER BY cust_channel_total DESC ) AS cust_channel_rank 
FROM 
(
SELECT channel_desc, s.cust_id, cust_last_name,cust_first_name, SUM (amount_sold) AS cust_channel_total
FROM sh.sales s
LEFT JOIN sh.channels ch ON s.channel_id=ch.channel_id
LEFT JOIN sh.customers cu ON cu.cust_id=s.cust_id
WHERE EXTRACT (YEAR FROM time_id)=1999
GROUP BY channel_desc, s.cust_id, cust_last_name,cust_first_name)
),
top300_01 AS (
SELECT  channel_desc, cust_id, cust_last_name,cust_first_name,cust_channel_total,
RANK () OVER (PARTITION BY channel_desc ORDER BY cust_channel_total DESC) AS cust_channel_rank 
FROM 
(
SELECT channel_desc, s.cust_id, cust_last_name,cust_first_name, SUM (amount_sold) AS cust_channel_total
FROM sh.sales s
LEFT JOIN sh.channels ch ON s.channel_id=ch.channel_id
LEFT JOIN sh.customers cu ON cu.cust_id=s.cust_id
WHERE EXTRACT (YEAR FROM time_id)=2001
GROUP BY channel_desc, s.cust_id, cust_last_name,cust_first_name)
)

SELECT t2.channel_desc,t2.cust_id,t2.cust_last_name,t2.cust_first_name,
ROUND (t2.cust_channel_total,2) AS "amount_sold"
FROM top300_98 t1 INNER JOIN top300_99 t2 ON
t1.cust_id=t2.cust_id AND t1.channel_desc=t2.channel_desc
INNER JOIN top300_01 t3 ON
t1.cust_id=t3.cust_id AND t1.channel_desc=t3.channel_desc
WHERE t1.cust_channel_rank <301 AND
t2.cust_channel_rank <301 AND
t3.cust_channel_rank <301;

--task 4
WITH cxr AS (
SELECT TO_CHAR(time_id, 'YYYY-MM') AS calendar_month_desc,prod_category, country_region,amount_sold
FROM sh.sales s
LEFT JOIN sh.customers c ON c.cust_id=s.cust_id
LEFT JOIN sh.countries co ON co.country_id=c.country_id
LEFT JOIN sh.products p ON s.prod_id=p.prod_id
WHERE EXTRACT (QUARTER FROM time_id)=1 AND
EXTRACT (YEAR FROM time_id)=2000 AND
country_region IN ('Americas','Europe')
)
SELECT DISTINCT calendar_month_desc, prod_category,
ROUND (SUM(CASE WHEN country_region='Americas' THEN amount_sold ELSE 0 END) OVER (PARTITION BY calendar_month_desc,prod_category)) AS "Americas SALES",
ROUND (SUM (CASE WHEN country_region='Europe' THEN amount_sold ELSE 0 END) OVER (PARTITION BY calendar_month_desc,prod_category)) AS "Europe SALES"
FROM cxr

ORDER BY calendar_month_desc, prod_category;

