
CREATE SCHEMA IF NOT EXISTS BL_3NF;
COMMIT;
CREATE TABLE IF NOT EXISTS BL_3NF."source" (
source_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
source_name varchar (255) UNIQUE NOT NULL DEFAULT 'n.a.' ,
source_desc varchar (255) NOT NULL DEFAULT 'n.a.'
);
COMMIT;
CREATE TABLE IF NOT EXISTS BL_3NF.payment_method (
payment_method_id int GENERATED ALWAYS AS IDENTITY NOT NULL,
payment_method_name varchar (255) NOT NULL DEFAULT 'n.a.',
source_id int NOT NULL DEFAULT -1,
CONSTRAINT uniq_method UNIQUE (payment_method_name, source_id)
);
COMMIT;
CREATE TABLE IF NOT EXISTS BL_3NF.city (
city_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
city_name varchar (255) NOT NULL UNIQUE DEFAULT 'n.a.',
source_id int NOT NULL DEFAULT -1
);
COMMIT;
CREATE TABLE IF NOT EXISTS BL_3NF.store (
store_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
store_name varchar (255) NOT NULL DEFAULT 'n.a.',
city_id int NOT NULL DEFAULT -1,
is_active boolean NOT NULL DEFAULT TRUE,
source_id int NOT NULL DEFAULT -1,
CONSTRAINT uniq_store UNIQUE (store_name,city_id,source_id)
);
COMMIT;



CREATE TABLE IF NOT EXISTS BL_3NF.cashier (
cashier_surr_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
cashier_src_id varchar (255) NOT NULL DEFAULT 'n.a.',
start_date date NOT NULL DEFAULT '1900-1-1',
end_date date NOT NULL DEFAULT '9999-12-31',
is_active boolean NOT NULL DEFAULT TRUE,
source_id int NOT NULL DEFAULT -1,
CONSTRAINT uniq_cashier UNIQUE (	)
);
COMMIT;
CREATE TABLE IF NOT EXISTS BL_3NF.store_cashier (
store_id int NOT NULL DEFAULT -1,
cashier_surr_id int NOT NULL DEFAULT -1,
start_dt date NOT NULL DEFAULT '1900-1-1',
end_dt date NOT NULL DEFAULT '9999-12-31',
|is_active boolean NOT NULL DEFAULT TRUE,
CONSTRAINT comp_key_store_cashier UNIQUE (store_id,cashier_surr_id,start_dt)
);
COMMIT;
CREATE TABLE IF NOT EXISTS BL_3NF.transactions 
(transaction_surr_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
transaction_src_id varchar (255) UNIQUE DEFAULT 'n.a',
store_id int NOT NULL,
cashier_surr_id int NOT NULL,
transaction_date date NOT NULL,
items_count int NOT NULL,
total_amount_ngn decimal NOT NULL,
payment_method_id int NOT NULL,
source_id int NOT NULL);
COMMIT;
INSERT INTO bl_3nf.source (source_name,source_desc) VALUES
('source1', 'Physical sales table'),
('source2','Online sales table');
COMMIT;

--in this task, i have double entries (1 from each source)for city,store etc. 

INSERT INTO BL_3NF.payment_method (payment_method_name, source_id)

SELECT DISTINCT s.payment_method_name, s.source_id
FROM (

SELECT DISTINCT payment_method AS payment_method_name,
(SELECT source_id FROM bl_3nf.source WHERE source_name = 'source1') AS source_id
FROM SA_SOURCE1.SRC_source1
WHERE payment_method IS NOT NULL

UNION
SELECT DISTINCT
payment_method AS payment_method_name,
(SELECT source_id FROM bl_3nf.source WHERE source_name = 'source2') AS source_id
FROM SA_SOURCE2.SRC_source2
WHERE payment_method IS NOT NULL

) s

LEFT JOIN BL_3NF.payment_method pm
    ON pm.payment_method_name = s.payment_method_name
   AND pm.source_id = s.source_id

WHERE pm.payment_method_id IS NULL;
COMMIT;
INSERT INTO BL_3NF.city (city_name,source_id) 
SELECT DISTINCT city, s.source_id FROM
(SELECT DISTINCT city,
(SELECT source_id FROM bl_3nf.source WHERE source_name = 'source1' )
FROM SA_SOURCE1.SRC_source1
WHERE CITY IS NOT NULL
UNION
SELECT DISTINCT city,
(SELECT source_id FROM bl_3nf.source WHERE source_name = 'source2' )
FROM SA_SOURCE2.SRC_source2
WHERE CITY IS NOT NULL) s
LEFT JOIN BL_3NF.city c ON s.city = c.city_name 
AND s.source_id= c.source_id
WHERE c.source_id IS NULL;
COMMIT;

INSERT INTO BL_3NF.store (store_name, city_id, source_id)
SELECT store_name, (SELECT city_id FROM BL_3NF.city c 
WHERE dist_cities.city =c.city_name AND dist_cities.source_id =c.source_id ),source_id from
(SELECT DISTINCT store_name, city,
(SELECT source_id FROM BL_3NF.source WHERE source_name='source1')
FROM sa_source1.src_source1) dist_cities
ON CONFLICT (store_name,city_id,source_id) DO NOTHING;
INSERT INTO BL_3NF.store (store_name, city_id, source_id)
SELECT store_name, (SELECT city_id FROM BL_3NF.city c 
WHERE dist_cities.city =c.city_name AND dist_cities.source_id =c.source_id ),source_id from
(SELECT DISTINCT store_name, city,
(SELECT source_id FROM BL_3NF.source WHERE source_name='source2')
FROM sa_source2.src_source2) dist_cities
ON CONFLICT (store_name,city_id,source_id) DO NOTHING;
COMMIT;

INSERT INTO BL_3NF.cashier (cashier_src_id,source_id)
SELECT DISTINCT cashier_id,
(SELECT source_id FROM BL_3NF.source WHERE source_name = 'source1')
FROM sa_source1.src_source1
ON CONFLICT (cashier_src_id,source_id) DO NOTHING;
INSERT INTO BL_3NF.cashier (cashier_src_id,source_id)
SELECT DISTINCT cashier_id,
(SELECT source_id FROM BL_3NF.source WHERE source_name = 'source2')
FROM sa_source2.src_source2
ON CONFLICT (cashier_src_id,source_id) DO NOTHING;
COMMIT;
with h as (
 select distinct cashier_id, store_name, city,transaction_date, 1 as source_id from sa_source1.src_source1
 union
 select distinct cashier_id, store_name, city,transaction_date , 2 as source_id from sa_source2.src_source2
),
maxxed as (
select cashier_id, store_name, city,transaction_date, source_id,
max (transaction_date) over (partition by cashier_id order by transaction_date desc) as last_date
from h),
final_locs as (
select cashier_id, store_name, city,transaction_date, last_date, source_id from maxxed where transaction_date = last_date
)
insert into bl_3nf.store_cashier (store_id,cashier_surr_id)

select store_id,cashier_surr_id from final_locs fl 
left join bl_3nf.cashier c on c.cashier_src_id = fl.cashier_id and c.source_id = fl.source_id
left join bl_3nf.city ci on ci.city_name = fl.city and ci.source_id = fl.source_id
left join bl_3nf.store s on fl.store_name = s.store_name  and fl.source_id = s.source_id  AND s.city_id = ci.city_id;
COMMIT;
INSERT INTO BL_3NF.transactions 
(transaction_src_id,store_id,transaction_date,cashier_surr_id,	items_count,total_amount_ngn,payment_method_id,source_id)
SELECT transaction_id, store_id,transaction_date,cashier_surr_id,items_count,total_amount_ngn,payment_method_id,1 FROM
sa_source1.src_source1 s1 
LEFT JOIN BL_3NF.city ci ON s1.city = ci.city_name AND ci.source_id = 1
LEFT JOIN BL_3NF.store st ON s1.store_name = st.store_name AND st.city_id = ci.city_id AND st.source_id = 1
LEFT JOIN BL_3NF.cashier ca ON s1.cashier_id = ca.cashier_src_id AND ca.source_id = 1
LEFT JOIN BL_3NF.payment_method pm ON pm.payment_method_name = payment_method AND pm.source_id = 1;

INSERT INTO BL_3NF.transactions 
(transaction_src_id,store_id,transaction_date,cashier_surr_id,	items_count,total_amount_ngn,payment_method_id,source_id)
SELECT transaction_id, store_id,transaction_date,cashier_surr_id,items_count,total_amount_ngn,payment_method_id,2 FROM
sa_source2.src_source2 s2 
LEFT JOIN BL_3NF.city ci ON s2.city = ci.city_name AND ci.source_id = 2
LEFT JOIN BL_3NF.store st ON s2.store_name = st.store_name AND st.city_id = ci.city_id AND st.source_id = 2
LEFT JOIN BL_3NF.cashier ca ON s2.cashier_id = ca.cashier_src_id AND ca.source_id = 2
LEFT JOIN BL_3NF.payment_method pm ON pm.payment_method_name = payment_method AND pm.source_id = 2
COMMIT;
