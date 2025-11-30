
--TASK 2
--1.Create a new user with the username "rentaluser" and the password "rentalpassword". Give the user the ability to connect to the database but no other permissions.

CREATE USER rentaluser LOGIN PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvdrental TO rentaluser;

--2.Grant "rentaluser" SELECT permission for the "customer" table. Сheck to make sure this permission works correctly—write a SQL query to select all customers.
GRANT SELECT ON public.customer TO rentaluser;
SET ROLE rentaluser;
SELECT * FROM public.customer;
RESET ROLE;

--3.Create a new user group called "rental" and add "rentaluser" to the group.
CREATE ROLE rental;
GRANT rental TO rentaluser;

--4.Grant the "rental" group INSERT and UPDATE permissions for the "rental" table. Insert a new row and update one existing row in the "rental" table under that role. 
GRANT INSERT ON public.rental TO rental;
GRANT UPDATE ON public.rental TO rental;
SET ROLE rental;
INSERT INTO public.rental (rental_date,inventory_id,customer_id, return_date, staff_id) VALUES
('2005-05-25 00:08:07+04',6,7,'2005-05-28 20:40:33+04',2)
RETURNING *;
RESET ROLE;

--5.Revoke the "rental" group's INSERT permission for the "rental" table. Try to insert new rows into the "rental" table make sure this action is denied.
REVOKE INSERT ON public.rental FROM rental;
SET ROLE rental;
INSERT INTO public.rental (rental_date,inventory_id,customer_id, return_date, staff_id) VALUES
('2005-05-25 00:08:07+04',6,7,'2005-05-28 20:40:33+04',2)
RETURNING *;
ERROR:  permission denied for table rental 

--6.Create a personalized role for any customer already existing in the dvd_rental database. The name of the role name must be client_{first_name}_{last_name} (omit curly brackets). The customer's payment and rental history must not be empty. 

SELECT customer_id FROM public.rental ORDER BY customer_id DESC;
SELECT customer_id FROM public.payment ORDER BY customer_id DESC;
--customer 599 has rental and payment history, let's look them up.
SELECT * FROM public.customer WHERE customer_id=599;
--His name is Austin Cintron.
CREATE ROLE client_austin_cintron LOGIN PASSWORD 'VOIDVOID999';

--TASK 3

ALTER TABLE public.rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment ENABLE ROW LEVEL SECURITY;

CREATE POLICY own_rental_rows ON public.rental FOR SELECT 
USING (customer_id=
(SELECT customer_id FROM public.customer WHERE 
CONCAT('client_',LOWER(first_name),'_',LOWER(last_name))=current_user)
);
CREATE POLICY own_payment_rows ON public.payment FOR SELECT 
USING (customer_id=
(SELECT customer_id FROM public.customer WHERE 
CONCAT('client_',LOWER(first_name),'_',LOWER(last_name))=current_user)
);
GRANT SELECT ON public.customer TO client_austin_cintron;
GRANT SELECT ON public.rental TO client_austin_cintron;
GRANT SELECT ON public.payment TO client_austin_cintron;
SET ROLE client_austin_cintron;

SELECT * FROM public.rental;
SELECT * FROM public.payment;
--the results from last 2 SELECT queries only show entries with customer_id=599.

RESET ROLE;