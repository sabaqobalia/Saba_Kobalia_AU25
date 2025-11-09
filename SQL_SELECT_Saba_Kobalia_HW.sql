--Part 1

--Task 1:The marketing team needs a list of animation movies between 2017 and 2019 to promote family-friendly content in an upcoming season in stores. Show all animation movies released during this period with rate more than 1, sorted alphabetically.

--Solution with join:
select f.title from public.film f inner join public.film_category fc on 
fc.film_id=f.film_id inner join public.category c on fc.category_id=c.category_id
where c.name='Animation' and f.release_year in (2017,2018,2019) and f. rental_rate > 1
order by f.title;


--Solution with CTE:
with animations as 
(select f.title,f.film_id, c.name, f.release_year, f.rental_rate 
from public.film f left join public.film_category fc on 
fc.film_id=f.film_id left join public.category c on fc.category_id=c.category_id)

select title from animations where rental_rate > 1 and release_year in (2017,2018,2019) and
name='Animation'
order by title;



--Solution with subquery:
select title from 
(select f.title,f.film_id, c.name, f.release_year, f.rental_rate 
from public.film f left join public.film_category fc on 
fc.film_id=f.film_id left join public.category c on fc.category_id=c.category_id)
where rental_rate > 1 and release_year in (2017,2018,2019) and
name='Animation'
order by title;


--Task 2:The finance department requires a report on store performance to assess profitability and plan resource allocation for stores after March 2017. Calculate the revenue earned by each rental store after March 2017 (since April) (include columns: address and address2 – as one column, revenue)

--Solution with join:

select CONCAT_WS(', ', a.address, a.address2) AS full_address, sum(amount) as revenue 
from
public.rental r inner join public.payment p on r.rental_id=p.rental_id
inner join public.inventory i on i.inventory_id=r.inventory_id
inner join public.store s on i.store_id=s.store_id inner join public.address a on
a.address_id=s.address_id
where payment_date > '2017-04-01' and payment_date<current_date
group by CONCAT_WS(', ', a.address, a.address2);


--Solution with cte:
with rev as
(select  CONCAT_WS(', ', a.address, a.address2) as full_address ,s.Store_id, p.payment_id, p.amount from
public.rental r inner join public.payment p on r.rental_id=p.rental_id
inner join public.inventory i on i.inventory_id=r.inventory_id
inner join public.store s on i.store_id=s.store_id  inner join public.address a on
a.address_id=s.address_id
where p.payment_date>'2017-04-01' and p.payment_date<current_date)



select   full_address, sum(amount) as revenue from rev
group by full_address;


--Solution with subquery:

select   full_address, sum(amount) as revenue from 
(select  CONCAT_WS(', ', a.address, a.address2) as full_address ,s.Store_id, p.payment_id, p.amount from
public.rental r inner join public.payment p on r.rental_id=p.rental_id
inner join public.inventory i on i.inventory_id=r.inventory_id
inner join public.store s on i.store_id=s.store_id  inner join public.address a on
a.address_id=s.address_id
where p.payment_date>'2017-04-01' and p.payment_date<current_date)


group by full_address;


--Task 3: The marketing department in our stores aims to identify the most successful actors since 2015 to boost customer interest in their films. Show top-5 actors by number of movies (released after 2015) they took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)

--Solution with join:
select a.first_name,a.last_name , count (f.film_id) as number_of_movies
from
public.film f inner join public. film_actor fa on f.film_id=fa.film_id inner join
public.actor a on fa.actor_id=a.actor_id
where f.release_year>2015
group by first_name, last_name order by  number_of_movies desc
limit 5;



--Solution with cte:
with msaxo as
(select a.first_name,a.last_name , f.film_id 
from
public.film f inner join public. film_actor fa on f.film_id=fa.film_id inner join
public.actor a on fa.actor_id=a.actor_id
where f.release_year>2015)

select first_name,  last_name, count (film_id)as number_of_movies from msaxo
group by first_name,last_name
order by number_of_movies desc
limit 5;


--Solution with subquery:


select first_name,  last_name, count (film_id)as number_of_movies 
from (select a.first_name,a.last_name , f.film_id 
from
public.film f inner join public. film_actor fa on f.film_id=fa.film_id inner join
public.actor a on fa.actor_id=a.actor_id
where f.release_year>2015)

group by first_name,last_name
order by number_of_movies desc
limit 5;


--Task 4:The marketing team needs to track the production trends of Drama, Travel, and Documentary films to inform genre-specific marketing strategies. Ырщц number of Drama, Travel, Documentary per year (include columns: release_year, number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), sorted by release year in descending order. Dealing with NULL values is encouraged)

--solution with join:
select release_year, c.name, 
count (case when c.name= 'Drama'then 1 end) as number_of_drama_movies,
count (case when c.name='Travel' then 1 end) as number_of_travel_movies,
count (case when c.name='Documentary' then 1 end) as number_of_documentary_movies
from
public.film f inner join public.film_category fc on f.film_id=fc.film_id
inner join public.category c on c.category_id=fc.category_id
where c.name IN ('Drama', 'Travel', 'Documentary')
group by release_year, c.name order by release_year desc;


--solution with cte:
with genre_films as (
select f.film_id, c.name as category, f.release_year from public.film f inner join
public.film_category fc on fc.film_id=f.film_id inner join public.category c on
c.category_id=fc.category_id where c.name in ('Drama', 'Travel', 'Documentary')
)


select release_year,
count (case when category='Drama' then 1 end) as number_of_drama_movies,
count (case when category='Travel' then 1 end) as number_of_travel_movies,
count (case when category='Documentary' then 1 end) as number_of_documentary_movies
from genre_films
group by release_year
order by release_year desc;


--solution with subquery:
select f.release_year,
(select count (*)
from public.film f2
join public.film_category fc2 on f2.film_id = fc2.film_id
join public.category c2 on fc2.category_id = c2.category_id
where c2.name = 'Drama' and f2.release_year = f.release_year) as number_of_drama_movies,

(select count(*)
from public.film f3
join public.film_category fc3 on f3.film_id = fc3.film_id
join public.category c3 on fc3.category_id = c3.category_id
where c3.name = 'Travel' and f3.release_year = f.release_year) as number_of_travel_movies,
   
(select count(*)
from public.film f4
join public.film_category fc4 on f4.film_id = fc4.film_id
join public.category c4 on fc4.category_id = c4.category_id
where c4.name = 'Documentary' and f4.release_year = f.release_year) as number_of_documentary_movies
from public.film f
group by f.release_year
order by f.release_year desc;


--Part 2
--1)The HR department aims to reward top-performing employees in 2017 with bonuses to recognize their contribution to stores revenue. Show which three employees generated the most revenue in 2017? 

with employee_revenue as (
select
r.staff_id,
sum(p.amount) as emp_revenue
from public.payment p 
inner join public.rental r on p.rental_id = r.rental_id
inner join public.inventory inv on r.inventory_id = inv.inventory_id
where extract(year from p.payment_date) = 2017
group by r.staff_id
order by emp_revenue desc
limit 3
),
last_store as
(select 
distinct on (r.staff_id) 
r.staff_id,
inv.store_id, 
 p.payment_date AS last_payment_date
from public.payment p 
inner join public.rental r on p.rental_id = r.rental_id
inner join public.inventory inv on r.inventory_id = inv.inventory_id
where extract(year from p.payment_date) = 2017
order by r.staff_id, p.payment_date DESC
)
select er.staff_id, er.emp_revenue, ls.store_id as last_store_id, s.first_name || ' ' || s.last_name as full_name
from employee_revenue er
inner join last_store ls on  ls.staff_id = er.staff_id
inner join public.staff s on er.staff_id = s.staff_id
order by er.emp_revenue desc;


--2)The management team wants to identify the most popular movies and their target audience age groups to optimize marketing efforts. Show which 5 movies were rented more than others (number of rentals), and what's the expected age of the audience for these movies? 

with everyrental as (
select r.rental_id, f.title, f.rating from public.film f inner join public.inventory i on 
f.film_id=i.film_id inner join public.rental r on r.inventory_id=i.inventory_id
)

select count (rental_id)as total_rentals, title, rating,
case 
when rating='G' then 'All ages'
when rating='PG' then '10+'
when rating='PG-13' then '13+'
when rating = 'R' then '17+'
when rating = 'NC-17' then 'Adults Only (18+)'
else 'Not Rated' end as expected_audience_age
from everyrental 
group by title, rating order by total_rentals desc
limit 5;

--Part 3:
--V1: gap between the latest release_year and current year per each actor

with factor as 
(
select a.actor_id, a.first_name, a.last_name, f.film_id, f.title, f.release_year from
public.film f inner join public.film_actor fa on f.film_id=fa.film_id inner join public.actor a on a.actor_id=fa.actor_id
)
select actor_id ,first_name, last_name, extract (year from current_date) - max (release_year) as years_inactive
from factor group by actor_id, first_name, last_name
order by years_inactive desc

--V2:gaps between sequential films per each actor
WITH actor_movie AS (SELECT  a.actor_id, a.first_name || ' ' ||a.last_name AS full_name,  f.release_year 
FROM public.actor  a              --First CTE gives us for each actor every movie release year where they played
 INNER JOIN public.film_actor fa ON a.actor_id = fa.actor_id
 INNER JOIN public.film f ON fa.film_id = f.film_id ),
actor_gaps AS (SELECT am1.full_name, am1.release_year AS year1,   MIN(am2.release_year) AS year2  
FROM actor_movie am1	--I used self join on CTE1 actor_movie since we need to calculate difference between years for each actor and the only way is to have those years twice in a table
INNER JOIN actor_movie am2 ON am1.actor_id = am2.actor_id AND	
am2.release_year > am1.release_year -- this ensures that we choose later released movies from second actor_movie am2 while keeping it lowest possible 'MIN(am2.release_year) AS year2' so sequential movies will be considered  
GROUP BY am1.full_name,am1.release_year)
SELECT full_name,	
MAX(year2-year1) AS biggest_gaps -- calculate maximum gap(difference between sequential movies) for each actor
FROM actor_gaps 
GROUP BY full_name
ORDER BY biggest_gaps DESC
LIMIT 10;
-- actor_films CTE gets each actor with their film release years. film_pairs CTE Self-joins the film years 
-- for each actor to calculate all possible year gaps where year2 > year1. actor_max_gaps CTE 
-- finds the maximum gap for each actor and final SELECT returns the top 10 actors with the longest 
-- acting gaps between films. (I might've used too many CTEs but I couldn't find any other solution).
