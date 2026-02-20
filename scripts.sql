CREATE SCHEMA IF NOT EXISTS SA_SOURCE1;
CREATE SCHEMA IF NOT EXISTS SA_SOURCE2;
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER csv_server
FOREIGN DATA WRAPPER file_fdw;


--Create foreign tables for raw data:
CREATE FOREIGN TABLE IF NOT EXISTS SA_SOURCE1.ext_source1 (
    transaction_id        VARCHAR,
    store_name            VARCHAR,
    city                  VARCHAR,
    transaction_date      VARCHAR,
    cashier_id            VARCHAR,
    cashier_gender        VARCHAR,
    cashier_birthday	  VARCHAR,
    customer_id           VARCHAR,
    customer_gender 	  VARCHAR,
    customer_birthday     VARCHAR,
    items_count           VARCHAR,
    total_amount_ngn      VARCHAR,
    payment_method        VARCHAR,
    discount_applied      VARCHAR,
    loyalty_points_earned VARCHAR,
    receipt_number        VARCHAR
)
SERVER csv_server
OPTIONS (
    filename 'D:/sadesktopo/EPAM/stage 2/dwh/task 1/source1.csv',
    format 'csv',
    header 'true'
);


CREATE FOREIGN TABLE IF NOT EXISTS SA_SOURCE2.ext_source2 (
    transaction_id        VARCHAR,
    store_name            VARCHAR,
    city                  VARCHAR,
    transaction_date      VARCHAR,
    cashier_id            VARCHAR,
    cashier_gender        VARCHAR,
    cashier_birthday	  VARCHAR,
    customer_id           VARCHAR,
    customer_gender 	  VARCHAR,
    customer_birthday     VARCHAR,
    items_count           VARCHAR,
    total_amount_ngn      VARCHAR,
    payment_method        VARCHAR,
    discount_applied      VARCHAR,
    loyalty_points_earned VARCHAR,
    receipt_number        VARCHAR
)
SERVER csv_server
OPTIONS (
    filename 'D:/sadesktopo/EPAM/stage 2/dwh/task 1/source2.csv',
    format 'csv',
    header 'true'
);



--create source tables
CREATE TABLE IF NOT EXISTS sa_source1.src_source1
( transaction_id          VARCHAR,
    store_name            VARCHAR,
    city                  VARCHAR,
    transaction_date      VARCHAR,
    cashier_id            VARCHAR,
    cashier_gender        VARCHAR,
    cashier_birthday	  VARCHAR,
    items_count           VARCHAR,
    customer_id           VARCHAR,
    customer_gender 	  VARCHAR,
    customer_birthday     VARCHAR,
    total_amount_ngn      VARCHAR,
    payment_method        VARCHAR,
    discount_applied      VARCHAR,
    loyalty_points_earned VARCHAR,
    receipt_number        VARCHAR)


CREATE TABLE IF NOT EXISTS sa_source2.src_source2
( transaction_id          VARCHAR,
    store_name            VARCHAR,
    city                  VARCHAR,
    transaction_date      VARCHAR,
    cashier_id            VARCHAR,
    cashier_gender        VARCHAR,
    cashier_birthday	  VARCHAR,
    items_count           VARCHAR,
    customer_id           VARCHAR,
    customer_gender 	  VARCHAR,
    customer_birthday     VARCHAR,
    total_amount_ngn      VARCHAR,
    payment_method        VARCHAR,
    discount_applied      VARCHAR,
    loyalty_points_earned VARCHAR,
    receipt_number        VARCHAR)


--insert into sources

INSERT INTO SA_SOURCE1.src_source1 (
    transaction_id          ,
    store_name            ,
    city                  ,
    transaction_date      ,
    cashier_id            ,
    cashier_gender        ,
    cashier_birthday	  ,
    items_count           ,
    customer_id           ,
    customer_gender 	  ,
    customer_birthday     ,
    total_amount_ngn      ,
    payment_method        ,
    discount_applied      ,
    loyalty_points_earned ,
    receipt_number
)
SELECT
    transaction_id          ,
    store_name            ,
    city                  ,
    transaction_date      ,
    cashier_id            ,
    cashier_gender        ,
    cashier_birthday	  ,
    items_count           ,
    customer_id           ,
    customer_gender 	  ,
    customer_birthday     ,
    total_amount_ngn      ,
    payment_method        ,
    discount_applied      ,
    loyalty_points_earned ,
    receipt_number
FROM SA_SOURCE1.ext_source1;


INSERT INTO SA_SOURCE2.src_source2 (
    transaction_id          ,
    store_name            ,
    city                  ,
    transaction_date      ,
    cashier_id            ,
    cashier_gender        ,
    cashier_birthday	  ,
    items_count           ,
    customer_id           ,
    customer_gender 	  ,
    customer_birthday     ,
    total_amount_ngn      ,
    payment_method        ,
    discount_applied      ,
    loyalty_points_earned ,
    receipt_number
)
SELECT
    transaction_id          ,
    store_name            ,
    city                  ,
    transaction_date      ,
    cashier_id            ,
    cashier_gender        ,
    cashier_birthday	  ,
    items_count           ,
    customer_id           ,
    customer_gender 	  ,
    customer_birthday     ,
    total_amount_ngn      ,
    payment_method        ,
    discount_applied      ,
    loyalty_points_earned ,
    receipt_number
FROM SA_SOURCE2.ext_source2;

--create schema for cleansing layer
CREATE SCHEMA IF NOT EXISTS BL_CL;

-create mapping for cashiers, customers, cities and stores so that we dont insert duplicates in the 3NF layer.

CREATE TABLE IF NOT EXISTS BL_CL.MAP_CASHIER (
cashier_surr_id int,
cashier_src_id varchar,
cashier_gender varchar,
cashier_birthday DATE,
source_table varchar,
source_system varchar,
CONSTRAINT unique_cashiers UNIQUE (cashier_src_id,source_table, source_system)
);

INSERT INTO BL_CL.MAP_CASHIER (cashier_src_id ,cashier_gender ,
cashier_birthday ,source_table ,source_system )
SELECT DISTINCT cashier_id, cashier_gender, cashier_birthday ::date, 'src_source1','sa_source1'
FROM sa_source1.src_source1
ON CONFLICT (cashier_src_id, source_table, source_system)
DO NOTHING;

INSERT INTO BL_CL.MAP_CASHIER (cashier_src_id ,cashier_gender ,
cashier_birthday ,source_table ,source_system )
SELECT DISTINCT cashier_id, cashier_gender, cashier_birthday ::date, 'src_source2','sa_source2'
FROM sa_source2.src_source2
ON CONFLICT (cashier_src_id, source_table, source_system)
DO NOTHING;

--now let's give them surrogate IDs

WITH max_id AS (
    SELECT COALESCE(MAX(cashier_surr_id), 0) AS last_id
    FROM BL_CL.MAP_CASHIER
),
new_cashiers AS (
    SELECT mc.*
    FROM BL_CL.MAP_CASHIER mc
    WHERE mc.cashier_surr_id IS NULL
),
assign AS (
    SELECT 
        nc.cashier_src_id,
        row_number() OVER (ORDER BY nc.cashier_src_id) + max_id.last_id AS new_id
    FROM new_cashiers nc, max_id
)
UPDATE BL_CL.MAP_CASHIER c
SET cashier_surr_id = a.new_id
FROM assign a
WHERE c.cashier_src_id = a.cashier_src_id;


CREATE TABLE IF NOT EXISTS bl_cl.map_customer(
customer_surr_id int,
customer_src_id varchar,
customer_gender varchar,
customer_birthday DATE,
source_table varchar,
source_system varchar,
CONSTRAINT unique_customer UNIQUE (customer_src_id, source_system, source_table)
);

INSERT INTO BL_CL.MAP_Customer (customer_src_id ,customer_gender ,
customer_birthday ,source_table ,source_system )
SELECT DISTINCT customer_id, customer_gender, customer_birthday ::date, 'src_source1','sa_source1'
FROM sa_source1.src_source1
ON CONFLICT (customer_src_id, source_system, source_table) DO NOTHING;

INSERT INTO BL_CL.MAP_Customer (customer_src_id ,customer_gender ,
customer_birthday ,source_table ,source_system )
SELECT DISTINCT customer_id, customer_gender, customer_birthday ::date, 'src_source2','sa_source2'
FROM sa_source2.src_source2
ON CONFLICT (customer_src_id, source_system, source_table) DO NOTHING;


WITH max_id AS (
    SELECT COALESCE(MAX(customer_surr_id), 0) AS last_id
    FROM BL_CL.MAP_CUSTOMER
),
new_customers AS (
    SELECT *
    FROM BL_CL.MAP_CUSTOMER
    WHERE customer_surr_id IS NULL
),
assign AS (
    SELECT 
        nc.customer_src_id,
        row_number() OVER (ORDER BY nc.customer_src_id) + max_id.last_id AS new_id
    FROM new_customers nc, max_id
)
UPDATE BL_CL.MAP_CUSTOMER c
SET customer_surr_id = a.new_id
FROM assign a
WHERE c.customer_src_id = a.customer_src_id;

CREATE TABLE IF NOT EXISTS bl_cl.map_city (city_id int, city_name varchar,source_table varchar,
source_system varchar,
CONSTRAINT unique_city UNIQUE(city_name,source_table,source_system));

INSERT INTO bl_cl.map_city  (city_name ,source_table ,
source_system )
SELECT DISTINCT city, 'src_source1', 'sa_source1' FROM sa_source1.src_source1
ON CONFLICT (city_name,source_table,source_system) DO NOTHING;

INSERT INTO bl_cl.map_city  (city_name ,source_table ,
source_system )
SELECT DISTINCT city, 'src_source2', 'sa_source2' FROM sa_source2.src_source2
ON CONFLICT (city_name,source_table,source_system) DO NOTHING;

WITH max_id AS (
    SELECT COALESCE(MAX(city_id), 0) AS last_id
    FROM BL_CL.MAP_CITY
),
new_cities AS (
    SELECT *
    FROM BL_CL.MAP_CITY
    WHERE city_id IS NULL
),
assign AS (
    SELECT nc.city_name,
           row_number() OVER (ORDER BY nc.city_name) + max_id.last_id AS new_id
    FROM new_cities nc, max_id
)
UPDATE BL_CL.MAP_CITY c
SET city_id = a.new_id
FROM assign a
WHERE c.city_name = a.city_name;


CREATE TABLE IF NOT EXISTS bl_cl.map_store (
store_id int, store_name varchar, store_city varchar, source_table varchar,
source_system varchar,
CONSTRAINT unique_store UNIQUE (store_name , store_city , source_table ,source_system)
);

INSERT INTO bl_cl.map_store (store_name,store_city,source_table, source_system)
SELECT DISTINCT store_name, city, 'src_source1','sa_source1'
FROM sa_source1.src_source1
ON CONFLICT (store_name , store_city , source_table ,source_system) DO NOTHING;

INSERT INTO bl_cl.map_store (store_name,store_city,source_table, source_system)
SELECT DISTINCT store_name, city, 'src_source2','sa_source2'
FROM sa_source2.src_source2
ON CONFLICT (store_name , store_city , source_table ,source_system) DO NOTHING;

WITH max_id AS (
    SELECT COALESCE(MAX(store_id), 0) AS last_id
    FROM BL_CL.MAP_STORE
),
new_stores AS (
    SELECT *
    FROM BL_CL.MAP_STORE
    WHERE store_id IS NULL
),
assign AS (
    SELECT nc.store_name, nc.store_city,
           row_number() OVER (ORDER BY nc.store_name, nc.store_city) + max_id.last_id AS new_id
    FROM new_stores nc, max_id
)
UPDATE BL_CL.MAP_STORE s
SET store_id = a.new_id
FROM assign a
WHERE s.store_name = a.store_name
  AND s.store_city = a.store_city;

CREATE TABLE IF NOT EXISTS bl_cl.map_payment_method (
payment_method_id int, pm_name varchar, source_table varchar, source_system varchar,
CONSTRAINT UNIQUE (pm_name , source_table , source_system)
);

INSERT INTO  bl_cl.map_payment_method (pm_name,source_table,source_system)
SELECT DISTINCT payment_method, 'src_source1', 'sa_source1' 
FROM sa_source1.src_source1
ON CONFLICT (pm_name , source_table , source_system) DO NOTHING;

INSERT INTO  bl_cl.map_payment_method (pm_name,source_table,source_system)
SELECT DISTINCT payment_method, 'src_source2', 'sa_source2' 
FROM sa_source2.src_source2
ON CONFLICT (pm_name , source_table , source_system) DO NOTHING;

WITH max_id AS (
    SELECT COALESCE(MAX(payment_method_id), 0) AS last_id
    FROM BL_CL.MAP_PAYMENT_METHOD
),
new_pm AS (
    SELECT *
    FROM BL_CL.MAP_PAYMENT_METHOD
    WHERE payment_method_id IS NULL
),
assign AS (
    SELECT nc.pm_name,
           row_number() OVER (ORDER BY nc.pm_name) + max_id.last_id AS new_id
    FROM new_pm nc, max_id
)
UPDATE BL_CL.MAP_PAYMENT_METHOD p
SET payment_method_id = a.new_id
FROM assign a
WHERE p.pm_name = a.pm_name;



