--task1
WITH cxrili AS (
SELECT country_region, 
SUM (SUM (amount_sold)) OVER w AS amount_sold ,
SUM (SUM(amount_sold)) OVER (PARTITION BY country_region,EXTRACT (YEAR FROM time_id)) AS amount_sold2,
EXTRACT (YEAR FROM time_id) AS calendar_year,channel_desc 
FROM sh.sales s 
LEFT JOIN sh.customers c ON s.cust_id=c.cust_id
LEFT JOIN sh.countries co ON c.country_id=co.country_id
lEFT JOIN sh.channels ch ON s.channel_id=ch.channel_id
where extract (YEAR FROM time_id) IN (1998,1999,2000,2001)
GROUP BY country_region,channel_desc,EXTRACT (YEAR FROM time_id)
WINDOW w AS (partition by country_region,channel_desc,EXTRACT (YEAR FROM time_id))
),

cxrili2 AS (
SELECT country_region, calendar_year, channel_desc, 
amount_sold, 
amount_sold*100/amount_sold2 as "% BY CHANNELS",
SUM (amount_sold)  OVER w2 *100/SUM (amount_sold2) OVER w2 AS "% PREVIOUS PERIOD"
FROM cxrili
WINDOW w2 AS  (PARTITION BY country_region,channel_desc ORDER BY calendar_year ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) 
)

SELECT country_region, calendar_year, channel_desc, 
to_char (amount_sold,'999,999,999   $') AS amount_sold,
to_char ("% BY CHANNELS",'999.99%') AS "% BY CHANNELS",
to_char (coalesce("% PREVIOUS PERIOD",0),'99.99%') AS "% PREVIOUS PERIOD",
to_char (coalesce (("% BY CHANNELS"-"% PREVIOUS PERIOD"),0),'99.99%') AS "% DIFF"
FROM cxrili2 WHERE calendar_year>1998
ORDER BY country_region,calendar_year, channel_desc;



--task 2

WITH cxrili AS (
SELECT amount_sold,time_id,
TO_CHAR (time_id, 'FMDay') AS day_name,
EXTRACT (week FROM time_id) AS calendar_week_number,
EXTRACT(ISODOW FROM time_id) AS numeric_day_week,
EXTRACT (doy FROM time_id) AS numeric_day_year
FROM sh.sales 
WHERE EXTRACT (YEAR FROM time_id)=1999
AND EXTRACT (week FROM time_id) in (48,49,50,51)
),
cxrili2 AS (
SELECT calendar_week_number,time_id,day_name, sum (amount_sold) as "sales",
SUM(SUM(amount_sold)) OVER (PARTITION BY calendar_week_number ORDER BY numeric_day_week ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum,
ROUND (
CASE
WHEN day_name = 'Monday' THEN 
AVG(SUM(amount_sold)) OVER (ORDER BY numeric_day_year ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING)
WHEN day_name='Friday' THEN
AVG(SUM(amount_sold)) OVER ( ORDER BY numeric_day_year ROWS BETWEEN 1 PRECEDING AND 2 FOLLOWING)
ELSE
AVG(SUM(amount_sold)) OVER ( ORDER BY numeric_day_year ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
END,2) AS centered_3_day_avg

FROM cxrili

GROUP BY calendar_week_number,time_id,day_name,numeric_day_week,numeric_day_year)

SELECT * FROM cxrili2 WHERE calendar_week_number > 48;
-- The example on learn.epam shows an incorrect value for centered 3 day avg. for week 49's monday, as it didn't take into account the weekend from week 48.


--task3
--i decided to use dvdrental for this task, i've practiced much more on this database and understand it better.
--let's calculate running total of payments per customer.
SELECT customer_id, payment_date, amount,
SUM(amount) OVER (PARTITION BY customer_id ORDER BY payment_date
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM payment;
--ROWS is used because we want a true row-by-row running total, independent of duplicate ORDER BY values.

--we need to find 7-day rolling sum of payments
SELECT payment_date,amount,
SUM(amount) OVER (ORDER BY payment_date
RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW) AS last_7_days_total
FROM payment;
--RANGE is needed because the frame is defined by a value interval (time), not by a fixed number of rows.

--if we want to count cumulative amount of rentals by rating
WITH cxrili AS (
SELECT f.rating,COUNT(*) AS rental_count
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.rating
)


SELECT rating, rental_count,
SUM(rental_count) OVER (ORDER BY rating
GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_by_rating
FROM cxrili 
--GROUPS is used because the calculation should take  rows  with different ratings as previous rows, rather than some range.
;



