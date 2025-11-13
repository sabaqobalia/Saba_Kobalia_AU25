--insert 6 real actors
INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Brad', 'Pitt', current_date
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE UPPER(first_name)='BRAD' AND UPPER(last_name)='PITT'
)
RETURNING*;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Casey', 'Affleck', current_date
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE UPPER(first_name)='CASEY' AND UPPER(last_name)='AFFLECK'
)RETURNING*	;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Owen', 'Wilson', current_date
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE UPPER(first_name)='OWEN' AND UPPER(last_name)='WILSON'
)RETURNING*;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Paul', 'Newman', current_date
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE UPPER(first_name)='PAUL' AND UPPER(last_name)='NEWMAN'
)RETURNING*;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Edward', 'Norton', current_date
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE UPPER(first_name)='EDWARD' AND UPPER(last_name)='NORTON'
)RETURNING*;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Edward', 'Furlong', current_date
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE UPPER(first_name)='EDWARD' AND UPPER(last_name)='FURLONG'
)RETURNING*;
COMMIT;

--Insert my 3 favorite movies in 'film'
INSERT INTO public.film (title, language_id, rental_duration, rental_rate)
SELECT 'The Assassination of Jesse James by the Coward Robert Ford', 1, 1, 4.99
WHERE NOT EXISTS (
    SELECT 1 FROM public.film WHERE UPPER(title)='THE ASSASSINATION OF JESSE JAMES BY THE COWARD ROBERT FORD'
)RETURNING*;

INSERT INTO public.film (title, language_id, rental_duration, rental_rate)
SELECT 'Cars', 1, 2, 9.99
WHERE NOT EXISTS (
    SELECT 1 FROM public.film WHERE UPPER(title)='CARS'
)RETURNING*;

INSERT INTO public.film (title, language_id, rental_duration, rental_rate)
SELECT 'American History X', 1, 3, 19.99
WHERE NOT EXISTS (
    SELECT 1 FROM public.film WHERE UPPER(title)='AMERICAN HISTORY X'
)RETURNING*;
COMMIT;




--Assign the actors AND movies
--film_actor already has composite key and constraint so no need for WHERE NOT EXISTS HERE. We will use ON CONFLICT DO NOTHING
INSERT INTO film_actor (actor_id,film_id,last_update) VALUES
(
(SELECT actor_id FROM public. actor WHERE UPPER(first_name)='BRAD' AND UPPER (last_name)='PITT'),
(SELECT film_id FROM public. film WHERE UPPER(title)='THE ASSASSINATION OF JESSE JAMES BY THE COWARD ROBERT FORD'),
 current_date
),
(
 (SELECT actor_id FROM public. actor WHERE UPPER(first_name)='CASEY' AND UPPER (last_name)='AFFLECK'),
 (SELECT film_id FROM public. film WHERE UPPER(title)='THE ASSASSINATION OF JESSE JAMES BY THE COWARD ROBERT FORD'),
 current_date
),
(
(SELECT actor_id FROM public. actor WHERE UPPER(first_name)='OWEN' AND UPPER (last_name)='WILSON'),
(SELECT film_id FROM public. film WHERE UPPER(title)='CARS'),
 current_date
),
(
(SELECT actor_id FROM public. actor WHERE UPPER(first_name)='PAUL' AND UPPER (last_name)='NEWMAN'),
(SELECT film_id FROM public. film WHERE UPPER(title)='CARS'),
 current_date
),
(
(SELECT actor_id FROM public. actor WHERE UPPER(first_name)='EDWARD' AND UPPER (last_name)='NORTON'),
(SELECT film_id FROM public. film WHERE UPPER(title)='AMERICAN HISTORY X'),
 current_date
),
(
(SELECT actor_id FROM public. actor WHERE UPPER(first_name)='EDWARD' AND UPPER (last_name)='FURLONG'),
(SELECT film_id FROM public. film WHERE UPPER(title)='AMERICAN HISTORY X'),
 current_date
)
ON CONFLICT (actor_id,film_id) DO NOTHING
RETURNING *;
--save changes
COMMIT;	

--update inventory
--i did not use WHERE NOT EXISTS here either because it would go against basic logic. one store can have multiple discs with the same film.
INSERT INTO public.inventory (film_id, store_id, last_update) VALUES
((SELECT film_id FROM public. film WHERE UPPER(title)='THE ASSASSINATION OF JESSE JAMES BY THE COWARD ROBERT FORD'),1,current_date),
((SELECT film_id FROM public. film WHERE UPPER(title)='CARS'),1,current_date),
((SELECT film_id FROM public. film WHERE UPPER(title)='AMERICAN HISTORY X'),1,current_date)

RETURNING *;
COMMIT;

--create rental entries

INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-05-05',
       i.inventory_id,
       c.customer_id,
       '2017-05-12',
       1,
       current_date
FROM public.inventory i
JOIN public.customer c ON UPPER(c.first_name)='SABA' AND UPPER(c.last_name)='KOBALIA'
WHERE i.film_id = (
    SELECT film_id FROM public.film
    WHERE UPPER(title)='THE ASSASSINATION OF JESSE JAMES BY THE COWARD ROBERT FORD'
)
AND NOT EXISTS (
    SELECT 1 FROM public.rental
    WHERE customer_id = c.customer_id AND inventory_id = i.inventory_id
)RETURNING*;

INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-05-05',
       i.inventory_id,
       c.customer_id,
       '2017-05-19',
       1,
       current_date
FROM public.inventory i
JOIN public.customer c ON UPPER(c.first_name)='SABA' AND UPPER(c.last_name)='KOBALIA'
WHERE i.film_id = (
    SELECT film_id FROM public.film
    WHERE UPPER(title)='CARS'
)
AND NOT EXISTS (
    SELECT 1 FROM public.rental
    WHERE customer_id = c.customer_id AND inventory_id = i.inventory_id
)RETURNING*;

INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-05-05',
       i.inventory_id,
       c.customer_id,
       '2017-05-26',
       1,
       current_date
FROM public.inventory i
JOIN public.customer c ON UPPER(c.first_name)='SABA' AND UPPER(c.last_name)='KOBALIA'
WHERE i.film_id = (
    SELECT film_id FROM public.film
    WHERE UPPER(title)='AMERICAN HISTORY X'
)
AND NOT EXISTS (
    SELECT 1 FROM public.rental
    WHERE customer_id = c.customer_id AND inventory_id = i.inventory_id
)RETURNING*;
COMMIT;



--create payment entries

INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    c.customer_id,
    1,
    r.rental_id,
    4.99,
    '2017-05-05'
FROM public.customer c
JOIN public.rental r ON r.customer_id = c.customer_id
JOIN public.inventory i ON r.inventory_id = i.inventory_id
JOIN public.film f ON i.film_id = f.film_id
WHERE UPPER(c.first_name)='SABA' AND UPPER(c.last_name)='KOBALIA'
  AND UPPER(f.title)='THE ASSASSINATION OF JESSE JAMES BY THE COWARD ROBERT FORD'
  AND NOT EXISTS (
      SELECT 1 FROM public.payment WHERE rental_id = r.rental_id AND customer_id = c.customer_id
  )RETURNING*;

INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    c.customer_id,
    1,
    r.rental_id,
    19.98,
    '2017-05-05'
FROM public.customer c
JOIN public.rental r ON r.customer_id = c.customer_id
JOIN public.inventory i ON r.inventory_id = i.inventory_id
JOIN public.film f ON i.film_id = f.film_id
WHERE UPPER(c.first_name)='SABA' AND UPPER(c.last_name)='KOBALIA'
  AND UPPER(f.title)='CARS'
  AND NOT EXISTS (
      SELECT 1 FROM public.payment WHERE rental_id = r.rental_id AND customer_id = c.customer_id
  )RETURNING*;

INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    c.customer_id,
    1,
    r.rental_id,
    59.97,
    '2017-05-05'
FROM public.customer c
JOIN public.rental r ON r.customer_id = c.customer_id
JOIN public.inventory i ON r.inventory_id = i.inventory_id
JOIN public.film f ON i.film_id = f.film_id
WHERE UPPER(c.first_name)='SABA' AND UPPER(c.last_name)='KOBALIA'
  AND UPPER(f.title)='AMERICAN HISTORY X'
  AND NOT EXISTS (
      SELECT 1 FROM public.payment WHERE rental_id = r.rental_id AND customer_id = c.customer_id
  )RETURNING*;
COMMIT;


