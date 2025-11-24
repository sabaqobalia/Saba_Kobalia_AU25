--Task 1. Create a view
CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS (
SELECT c.name AS category, SUM(amount) AS revenue FROM
public.payment p 
LEFT JOIN public.rental r ON r.rental_id=p.rental_id
LEFT JOIN public.inventory i ON i.inventory_id=r.inventory_id 
LEFT JOIN public.film f ON i.film_id=f.film_id 
LEFT JOIN public.film_category fc ON fc.film_id=f.film_id 
LEFT JOIN public.category c ON
fc.category_id=c.category_id
WHERE 
 EXTRACT (quarter FROM r.rental_date)=EXTRACT (quarter FROM current_date) AND 
 EXTRACT (year FROM r.rental_date)=EXTRACT (year FROM current_date)
GROUP BY c.name
HAVING COUNT(r.rental_id)>0
ORDER BY revenue DESC);

--Task 2. Create a query language functions
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(p_quarter INT, p_year INT)
RETURNS TABLE(category TEXT, total_revenue NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY
SELECT c.name AS category, SUM(p.amount) AS total_revenue
FROM payment p
LEFT JOIN public.rental r ON r.rental_id = p.rental_id
LEFT JOIN public.inventory i ON i.inventory_id = r.inventory_id
LEFT JOIN public.film f ON i.film_id = f.film_id
LEFT JOIN public.film_category fc ON fc.film_id = f.film_id
LEFT JOIN public.category c ON fc.category_id = c.category_id
WHERE EXTRACT(YEAR FROM r.rental_date) = p_year
      AND EXTRACT(QUARTER FROM r.rental_date) = p_quarter
GROUP BY c.name
HAVING SUM(p.amount) > 0
ORDER BY total_revenue DESC;
END;
$$;

--Task 3  Create procedure language functions.
CREATE OR REPLACE FUNCTION most_popular_films_by_countries (IN function_country text[])
RETURNS TABLE (country text, title text, rating text, film_language text, film_length smallint, release_year integer)
LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY

WITH countryrental AS (
SELECT  co.country,f.title,f.rating,l.name, f.length, f.release_year, COUNT(*) AS rental_count FROM public.customer c 
LEFT JOIN public.address a ON c.address_id=a.address_id
LEFT JOIN public.city ci ON ci.city_id=a.city_id 
LEFT JOIN public.country co ON co.country_id=ci.country_id 
LEFT JOIN public.rental r ON r.customer_id=c.customer_id 
LEFT JOIN public.inventory i ON r.inventory_id=i.inventory_id 
LEFT JOIN public.film f ON f.film_id=i.film_id
LEFT JOIN public.language l ON l.language_id=f.language_id
GROUP BY f.title, co.country,f.rating,l.name, f.length, f.release_year
)
SELECT cr1.country,cr1.title,cr1.rating::text, cr1.name::text AS film_language , cr1.length as film_length, cr1.release_year::int FROM countryrental cr1 
WHERE
rental_count=(
SELECT MAX(rental_count) FROM countryrental cr2 WHERE cr1.country=cr2.country 
) AND  cr1.country=ANY(function_country);   
END;
$$;
--task 4

CREATE OR REPLACE FUNCTION films_in_stock_by_title (IN word text)
RETURNS TABLE (inventory_id int, title text)
LANGUAGE plpgsql
AS $$
DECLARE
    matches INT;
BEGIN
    
    SELECT COUNT(*)
    INTO matches
    FROM public.inventory i
    JOIN public.film f ON f.film_id = i.film_id
    WHERE f.title ILIKE '%'||word||'%'
      AND NOT EXISTS (
            SELECT 1 FROM rental r
            WHERE r.inventory_id = i.inventory_id
              AND r.return_date IS NULL
      );

    
    IF matches = 0 THEN
        RAISE NOTICE 'No films in stock match: %', word;
        RETURN;
    END IF;

    
    RETURN QUERY
    SELECT i.inventory_id, f.title
    FROM public.inventory i
    JOIN public.film f ON f.film_id = i.film_id
    WHERE f.title ILIKE '%'||word||'%'
      AND NOT EXISTS (
            SELECT 1 FROM rental r
            WHERE r.inventory_id = i.inventory_id
              AND r.return_date IS NULL
      );

END;
$$;

--task5
CREATE OR REPLACE FUNCTION new_movie (new_title text, release_year int DEFAULT EXTRACT(YEAR FROM CURRENT_DATE), new_language text DEFAULT 'Klingon')
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE lang_id int; new_id int;
BEGIN
SELECT language_id INTO lang_id
FROM public.language WHERE
name=new_language;
IF lang_id IS NULL THEN
RAISE EXCEPTION 'Language "%" does not exist in table "language"', new_language;
END IF;
SELECT MAX(film_id)+1 INTO new_id
FROM public.film;

INSERT INTO public.film(film_id,title,language_id,rental_rate,rental_duration,replacement_cost) VALUES
                       (new_id,new_title,lang_id,4.99,         3,             19.99);
RAISE NOTICE 'New movie "%" successfully added', new_title;
END;
$$;
