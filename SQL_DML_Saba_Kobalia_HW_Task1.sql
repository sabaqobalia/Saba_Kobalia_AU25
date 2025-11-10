--First let's insert 6 real actors from my 3 favorite movies, 2 from each.
INSERT INTO public.actor (actor_id, first_name,last_name,last_update) VALUES
(201,'Brad','Pitt', current_date),
(202,'Casey','Affleck',current_date),
(203,'Owen', 'Wilson', current_date),
(204,'Paul', 'Newman', current_date),
(205,'Edward', 'Norton',current_date),
(206,'Edward','Furlong', current_date)
RETURNING *;

--save changes
COMMIT;

--Create the three movie entries in film
INSERT INTO public.film (film_id,title,language_id,rental_duration,rental_rate) VALUES
(1001,'The Assassination of Jesse James by the Coward Robert Ford',1,1,4.99),
(1002,'Cars',1,2,9.99),
(1003, 'American History X',1,3,19.99)
RETURING *;
--save changes
COMMIT;

--Assign the actors and movies
INSERT INTO public.film_actor (actor_id,film_id,last_update) VALUES
(201,1001,current_date),
(202,1001,current_date),
(203,1002,current_date),
(204,1002,current_date),
(205,1003,current_date),
(206,1003,current_date)
RETURNING *;
--save changes
COMMIT;

--Add the movies in store 1
INSERT INTO public.inventory (inventory_id, film_id, store_id, last_update) VALUES
(4582,1001,1,current_date),
(4583,1002,1,current_date),
(4584,1003,1,current_date)
RETURNING *;
--save changes
COMMIT;

--let's see which customers have more than 43 rentals and more than 43 payments
WITH payc AS (SELECT customer_id,COUNT (payment_id) AS no_payments FROM public.payment GROUP BY customer_id HAVING COUNT (payment_id)>43  ),

rentalc AS (SELECT customer_id, COUNT(rental_id) as no_rentals FROM public.rental  GROUP BY customer_id HAVING COUNT (rental_id)>43 ORDER BY customer_id)
SELECT pa.customer_id, no_payments, no_rentals FROM payc pa LEFT JOIN rentalc ra ON ra.customer_id=pa.customer_id;

--Customer 1 has 64 and 64, they will do. Let's add me as customer 1
UPDATE public.customer SET first_name='SABA',last_name='KOBALIA',email='SABAQOBALIA12@gmail.com', last_update=current_date WHERE customer_id=1
RETURNING *;
--save changes
COMMIT;

--Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
DELETE FROM public.payment WHERE  customer_id=1;
COMMIT;
DELETE FROM public.rental WHERE customer_id=1;
COMMIT;
--Create entries for rentals

INSERT INTO public.rental (rental_id, rental_date,inventory_id,customer_id, return_date,staff_id,last_update) VALUES
(32295,'2017-05-05',4582,1, '2017-05-12', 1,current_date),
(32296,'2017-05-05',4583,1,'2017-05-19',1,current_date),
(32297,'2017-05-05',4584,1,'2017-05-26',1,current_date)
RETURNING *
--save changes
COMMIT;
--Create payment entries
INSERT INTO public.payment (payment_id,customer_id,staff_id,rental_id,amount,payment_date) VALUES
(48143,1,1,32295,4.99,'2017-05-05'),
(48144,1,1,32296,19.98,'2017-05-05'),
(48145,1,1,32297,59.97,'2017-05-05')
RETURNING *;
COMMIT;
