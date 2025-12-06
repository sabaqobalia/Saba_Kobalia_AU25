--3. Create a physical database with a separate database and schema and give it an appropriate domain-related name

CREATE DATABASE museum;

CREATE SCHEMA IF NOT EXISTS  main_schema;

CREATE TABLE IF NOT EXISTS  main_schema.item_type 
(item_type_id serial PRIMARY KEY, item_type_name varchar (50) UNIQUE);

CREATE TABLE IF NOT EXISTS  main_schema.hall 
(hall_id serial PRIMARY KEY, "size" decimal,"floor" int, hall_name varchar(50) UNIQUE);

CREATE TABLE IF NOT EXISTS  main_schema.storage 
(storage_id serial PRIMARY KEY, "location" varchar(50) UNIQUE, "size" decimal,"security" varchar(50));

CREATE TABLE IF NOT EXISTS  main_schema.item
(item_id serial PRIMARY KEY,type_id smallint,item_name varchar(50) UNIQUE,manufactured_year int,market_value int,hall_id int, storage_id int,
last_update date DEFAULT current_date,
CONSTRAINT fk_item_type FOREIGN KEY (type_id) REFERENCES main_schema.item_type(item_type_id),
CONSTRAINT fk_item_hall FOREIGN KEY (hall_id) REFERENCES main_schema.hall (hall_id),
CONSTRAINT fk_storage_hall FOREIGN KEY (storage_id) REFERENCES main_schema.storage(storage_id),
CONSTRAINT valid_location CHECK (
                                (hall_id IS NULL AND storage_id IS NOT NULL) OR
                                (hall_id IS NOT NULL AND storage_id IS NULL) -- an item should either be in a storage or a hall. never in both and never in neither.
)
);
--forgot to add default, let's do it now
ALTER TABLE main_schema.item
ALTER COLUMN last_update SET DEFAULT current_date;


CREATE TABLE IF NOT EXISTS main_schema.position 
(position_id serial PRIMARY KEY, position_name varchar(50) UNIQUE, description text);

CREATE TABLE IF NOT EXISTS main_schema.employee
(employee_id serial PRIMARY KEY, first_name varchar (50), last_name varchar (50),position_id int,salary decimal,contract_until date,
CONSTRAINT valid_position FOREIGN KEY (position_id) REFERENCES main_schema.position (position_id));

CREATE TABLE IF NOT EXISTS  main_schema.exhibition 
(exhibition_id serial PRIMARY KEY, exhibition_name varcjar(50),hall_id int, exhibition_date date, price decimal,

CONSTRAINT exhi_hall FOREIGN KEY (hall_id) REFERENCES main_schema.hall(hall_id)
);


CREATE TABLE IF NOT EXISTS  main_schema.exhibition_employee
(exhibiton_id int, employee_id int,
CONSTRAINT assign_exhi FOREIGN KEY (exhibiton_id) REFERENCES main_schema.exhibition (exhibition_id),
CONSTRAINT assign_emplo FOREIGN KEY (employee_id) REFERENCES main_schema.employee (employee_id)
);-- forgot to add unique constraint
ALTER TABLE main_schema.exhibition_employee ADD CONSTRAINT no_double_entry
UNIQUE (exhibition_id,employee_id)

CREATE TABLE IF NOT EXISTS  main_schema.visitor
(visitor_id serial PRIMARY KEY, first_name varchar(50), last_name varchar(50), birth_date date, "VIP?" boolean);

CREATE TABLE IF NOT EXISTS  main_schema.ticket 
(ticket_id serial PRIMARY KEY,exhibition_id int, visitor_id int, sale_date date DEFAULT current_date,
CONSTRAINT exhi_ticket FOREIGN KEY (exhibition_id) REFERENCES main_schema.exhibition (exhibition_id),
CONSTRAINT exhi_visitor FOREIGN KEY (visitor_id) REFERENCES main_schema.visitor (visitor_id)
);

--Use ALTER TABLE to add at least 5 check constraints across the tables to restrict certain values
ALTER TABLE main_schema.hall ADD CONSTRAINT valid_floor
CHECK ("floor" <= 5); -- our building only has 5 floors.

ALTER TABLE main_schema.ticket ADD CONSTRAINT valid_date
CHECK (sale_date<=current_date); --can't record sales that haven't happened yet.


ALTER TABLE main_schema.visitor ADD CONSTRAINT valid_birthday
CHECK (birth_date between '1900-01-01' AND current_date);--same principle.

ALTER TABLE main_schema.storage ADD CONSTRAINT sec_level
CHECK ("security" IN ('Very high','High','Medium', 'Low'));

ALTER TABLE main_schema.exhibition ADD CONSTRAINT valid_exhi_price
CHECK (price<1000); -- our events are never that expensive.


ALTER TABLE main_schema.item ADD CONSTRAINT valid_manu_date
CHECK (manufactured_year < EXTRACT (YEAR FROM current_date));-- museums usually have items from the past.

--Populate the tables with the sample data generated, ensuring each table has at least 6+ rows (for a total of 36+ rows in all the tables) for the last 3 months.

INSERT INTO main_schema.item_type (item_type_name) VALUES
('Painting'), ('Document'), ('Jewelry'),('Textile'),('Sculpture'),('Fossil')
ON CONFLICT (item_type_name) DO NOTHING
RETURNING*;


INSERT INTO main_schema.hall ("size","floor",hall_name) VALUES
(85,2,'Neanderthal Hall'),
(30,1,'Red Hall'),
(100.5,1,'Main Hall'),
(65,5,'Top Hall'),
(55,4,'Italian Paintings Hall'),
(90.2,3,'Very Interesting Hall')
ON CONFLICT (hall_name) DO NOTHING
RETURNING*
;


INSERT INTO main_schema.storage ("location","size","security") VALUES
('Beliashvili 20',1500,'Medium'),
('Bush st. 19', 230,'Medium'),
('Pekini ave. 99',56.2,'High'),
('David highway 3rd turn',50,'Very high'),
('Tsereteli ave. 40b',70,'Medium'),
('Chinatown 3rd turn', 45.4,'Medium')
RETURNING*;



INSERT INTO main_schema.item (type_id,item_name,manufactured_year,market_value,hall_id,storage_id) VALUES
(
(SELECT item_type_id FROM main_schema.item_type WHERE UPPER(item_type_name)='PAINTING'),
'A cool painting',1900,25000,
(SELECT hall_id FROM main_schema.hall  WHERE UPPER(hall_name)='ITALIAN PAINTINGS HALL'),NULL
),
(
(SELECT item_type_id FROM main_schema.item_type WHERE UPPER(item_type_name)='FOSSIL'),
'Capybara bones', -50000,100000,
(SELECT hall_id FROM main_schema.hall  WHERE UPPER(hall_name)='MAIN HALL'),NULL
),
(
(SELECT item_type_id FROM main_schema.item_type WHERE UPPER(item_type_name)='TEXTILE'),
'Duck Scarf', 1600, 19000,NULL,2
),
(
(SELECT item_type_id FROM main_schema.item_type WHERE UPPER(item_type_name)='DOCUMENT'),
'Important letter',1799,5000,
(SELECT hall_id FROM main_schema.hall  WHERE UPPER(hall_name)='VERY INTERESTING HALL'),NULL
),

(
(SELECT item_type_id FROM main_schema.item_type WHERE UPPER(item_type_name)='SCULPTURE'),
'Lincoln Statue',2000,20000,
(SELECT hall_id FROM main_schema.hall  WHERE UPPER(hall_name)='RED HALL'),NULL
),

((SELECT item_type_id FROM main_schema.item_type WHERE UPPER(item_type_name)='JEWELRY'),
'Lebrons ring',2015,30000,
(SELECT hall_id FROM main_schema.hall  WHERE UPPER(hall_name)='TOP HALL'),NULL


)


RETURNING*
;


INSERT INTO main_schema.position (position_name,description) VALUES 
('Security Guard', 'Guards items'),
('Driver','Drives transport vehicles'),
('Exhibition manager','Main person in planning and hosting events'),
('Guide','Enertains and informs the guests'),
('Marketing specialist', 'Promotes our products'),
('Collections manager', 'Catalogs and cares for stored items')
RETURNING*
;

INSERT INTO main_schema.employee (first_name,last_name,position_id,salary,contract_until) VALUES
('Bobert','Austin',(SELECT position_id FROM main_schema.position WHERE UPPER(position_name)='DRIVER'),
3000,'2026-12-31'
),
('Maya','Jikia',(SELECT position_id FROM main_schema.position WHERE UPPER(position_name)='MARKETING SPECIALIST'),
5000,'2027-06-30'
),

('Gordon','Cash',(SELECT position_id FROM main_schema.position WHERE UPPER(position_name)='EXHIBITION MANAGER'),
4500,'2026-05-30'
),

('Alan','Bean', (SELECT position_id FROM main_schema.position WHERE UPPER(position_name)='GUIDE'),
2999, '2028-07-30'
),
('Mercy', 'Spears', (SELECT position_id FROM main_schema.position WHERE UPPER(position_name)='EXHIBITION MANAGER'),
1000, '2025-12-31'
),
('Hal','Jordan', (SELECT position_id FROM main_schema.position WHERE UPPER(position_name)='GUIDE'),
6500,'2026-09-25'
)
RETURNING*
;

INSERT INTO main_schema.exhibition (exhibition_name, hall_id,exhibition_date,price) VALUES
('Good exhibition',(SELECT hall_id FROM main_schema.hall WHERE UPPER (hall_name)='MAIN HALL'),'2025-11-20',100
),
(
'Nice exhibition',(SELECT hall_id FROM main_schema.hall WHERE UPPER (hall_name)='TOP HALL'), '2025-10-10',120
),
(
'Interesting stuff',(SELECT hall_id FROM main_schema.hall WHERE UPPER (hall_name)='ITALIAN PAINTINGS HALL'),'2026-01-10',77
),
(
'Old bones',(SELECT hall_id FROM main_schema.hall WHERE UPPER (hall_name)='RED HALL'),'2026-07-07', 89
),
(
'Art fest',(SELECT hall_id FROM main_schema.hall WHERE UPPER (hall_name)='MAIN HALL'), '2025-09-01',25
),
(
'Good art',(SELECT hall_id FROM main_schema.hall WHERE UPPER (hall_name)='VERY INTERESTING HALL'), '2025-02-08',70
)
RETURNING*
;


INSERT INTO main_schema.exhibition_employee ( employee_id,exhibition_id) VALUES
(
(SELECT employee_id FROM main_schema.employee WHERE UPPER (first_name)='GORDON' AND UPPER(last_name)='CASH'),
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='OLD BONES')
),
(
(SELECT employee_id FROM main_schema.employee WHERE UPPER (first_name)='ALAN' AND UPPER(last_name)='BEAN'),
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='OLD BONES')
),
(
(SELECT employee_id FROM main_schema.employee WHERE UPPER (first_name)='MERCY' AND UPPER(last_name)='SPEARS'),
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='OLD BONES')
),
(
(SELECT employee_id FROM main_schema.employee WHERE UPPER (first_name)='GORDON' AND UPPER(last_name)='CASH'),
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='ART FEST')
),
(
(SELECT employee_id FROM main_schema.employee WHERE UPPER (first_name)='ALAN' AND UPPER(last_name)='BEAN'),
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='ART FEST')
),
(
(SELECT employee_id FROM main_schema.employee WHERE UPPER (first_name)='MERCY' AND UPPER(last_name)='SPEARS'),
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='ART FEST')
)



RETURNING *
;

INSERT INTO main_schema.visitor (first_name, last_name,birth_date, "VIP?") VALUES
('Ashton','Balldwin','1988-01-06',FALSE),
('Bubu','Alyan','2000-12-17',TRUE),
('Armen','Holden','1966-05-11',FALSE),
('Oran','Gutan','2005-11-14',TRUE),
('Alika','Thelion','1980-09-25',FALSE),
('Guru','Burden','1999-08-21',FALSE)

RETURNING *
;



INSERT INTO main_schema.ticket (exhibition_id,visitor_id) VALUES
(
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='ART FEST'),
(SELECT visitor_id FROM  main_schema.visitor WHERE UPPER (first_name)='ALIKA' AND UPPER (last_name)='THELION')
),
(
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='INTERESTING STUFF'),
(SELECT visitor_id FROM  main_schema.visitor WHERE UPPER (first_name)='GURU' AND UPPER (last_name)='BURDEN')
),
(
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='GOOD EXHIBITION'),
(SELECT visitor_id FROM  main_schema.visitor WHERE UPPER (first_name)='BUBU' AND UPPER (last_name)='ALYAN')
),
(
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='OLD BONES'),
(SELECT visitor_id FROM  main_schema.visitor WHERE UPPER (first_name)='ARMEN' AND UPPER (last_name)='HOLDEN')
),
(
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='GOOD ART'),
(SELECT visitor_id FROM  main_schema.visitor WHERE UPPER (first_name)='ORAN' AND UPPER (last_name)='GUTAN')
),
(
(SELECT exhibition_id FROM main_schema.exhibition WHERE UPPER (exhibition_name)='ART FEST'),
(SELECT visitor_id FROM  main_schema.visitor WHERE UPPER (first_name)='ASHTON' AND UPPER (last_name)='BALLDWIN')
)


RETURNING *;
--5.1 Create a function that updates data in one of your tables.
CREATE OR REPLACE FUNCTION update_employee (function_emp_id int,new_f_name text, new_l_name text, new_position_id int, new_salary decimal, new_contract_until date)
RETURNS TABLE (out_employee_id int, out_fname varchar (50), out_lname varchar (50), out_posID int, out_salary decimal, out_contract_date date)
LANGUAGE plpgsql
AS 
$$
BEGIN
RETURN QUERY

UPDATE  main_schema.employee SET first_name=new_f_name,
last_name=new_l_name,
position_id=new_position_id,
salary=new_salary,
contract_until=new_contract_until
WHERE employee_id=function_emp_id
RETURNING employee_id,first_name,last_name,position_id,salary,contract_until;
END;
$$;






--5. 2 Create a function that adds a new transaction to your transaction table. 
CREATE OR REPLACE FUNCTION new_item (new_name text,new_item_type text,new_year int ,new_value int,new_hall text,new_storage int)
RETURNS TABLE (out_item_id int,out_item_type_id smallint,out_item_name varchar(50) ,out_manufactured_year int, 
out_market_value int,out_hall_id int,out_storage_id int)
LANGUAGE plpgsql
AS
$$
DECLARE v_hall int; v_type int;
BEGIN
IF EXISTS
(SELECT 1 FROM main_schema.item WHERE main_schema.item.item_name=new_name) THEN
RAISE EXCEPTION 'Item % already in database', new_name;
END IF;
SELECT main_schema.hall.hall_id INTO v_hall FROM main_schema.hall WHERE
hall_name=new_hall;
SELECT main_schema.item_type.item_type_id INTO v_type FROM main_schema.item_type WHERE
item_type_name=new_item_type;
RETURN QUERY
INSERT INTO main_schema.item (item_type_id,item_name,manufactured_year,market_value,hall_id,storage_id) VALUES
(v_type,new_name,new_year,new_value,v_hall,new_storage)
RETURNING item_id, item_type_id, item_name, manufactured_year, market_value, hall_id, storage_id;
END;
$$;


--6. Create a view that presents analytics for the most recently added quarter in your database. Ensure that the result excludes irrelevant fields such as surrogate keys and duplicate entries.
CREATE OR REPLACE VIEW current_quarter_revenue
AS 
SELECT e.exhibition_name, SUM (e.price) FROM main_schema.ticket t  LEFT JOIN
main_schema.exhibition e ON t.exhibition_id=e.exhibition_id
WHERE EXTRACT (QUARTER FROM sale_date)= EXTRACT (QUARTER FROM current_date)
GROUP BY e.exhibition_name;



--7. Create a read-only role for the manager. This role should have permission to perform SELECT queries on the database tables, and also be able to log in. 
CREATE ROLE manager_readonly
WITH LOGIN
PASSWORD 'ManagerPass' 
NOINHERIT;












