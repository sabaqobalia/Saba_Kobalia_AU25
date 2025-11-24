CREATE DATABASE Subway;
--right click on Subway and chreate a new schema
CREATE SCHEMA IF NOT EXISTS new_schema;

--right click on new_schema and create tables.
CREATE TABLE IF NOT EXISTS  new_schema.Stations 
(station_id serial PRIMARY KEY,
s_name varchar(20) UNIQUE,
s_location varchar(50),
status varchar(10) CHECK (status IN ('Active','Under repair'))
);
CREATE TABLE IF NOT EXISTS new_schema.Lines
(line_id serial PRIMARY KEY,
 l_name varchar (20) UNIQUE,
 route_description text,
 frequency smallint CHECK (frequency>0)
);
CREATE TABLE IF NOT EXISTS new_schema.Stations_lines (
 station_id int NOT NULL,
 line_id int NOT NULL,
 position_in_line smallint,
 CONSTRAINT fk_station
  FOREIGN KEY (station_id)
  REFERENCES new_schema.Stations(station_id),
 CONSTRAINT fk_line
 FOREIGN KEY (line_id)
 REFERENCES new_schema.Lines(line_id)
); -- forgot to add UNIQUE constraint, let's do it now.
ALTER TABLE new_schema.stations_lines ADD CONSTRAINT composite_key2 UNIQUE (station_id,line_id);

CREATE TABLE IF NOT EXISTS new_schema.schedules 
(schedule_id serial PRIMARY KEY,
departure_station int NOT NULL,
arrival_station int NOT NULL,
departure_time time,
arrival_time time,
CONSTRAINT fk_departure
FOREIGN KEY (departure_station) REFERENCES new_schema.stations(station_id),
CONSTRAINT fk_arrival
 FOREIGN KEY (arrival_station) REFERENCES new_schema.stations(station_id)
); -- forgot to add UNIQUE constraint, let's do it now.
ALTER TABLE new_schema.schedules  ADD CONSTRAINT composite_key3 unique (departure_time,departure_station);
CREATE TABLE IF NOT EXISTS new_schema.trains(
train_ID serial PRIMARY KEY,
line_id int NOT NULL,
capacity smallint CHECK (capacity>0),
manufactured int CHECK (manufactured BETWEEN 1900 AND EXTRACT(YEAR FROM current_date)),
status varchar (10) CHECK (status in('Employed','Stored','Under repair')),
schedule_id int,
CONSTRAINT FK_line FOREIGN KEY (line_id) REFERENCES new_schema.lines(line_id)
);
CREATE TABLE IF NOT EXISTS new_schema.positions (
position_id serial PRIMARY KEY,
position_name varchar (30) UNIQUE,
position_description varchar(50)

);

CREATE TABLE IF NOT EXISTS new_schema.employee (
employee_id serial PRIMARY KEY,
first_name varchar (10),
last_name varchar (20),
position_id int NOT NULL,
salary decimal CHECK (salary>0),
gender varchar (6) CHECK (gender IN ('Male','Female')),
CONSTRAINT fk_position FOREIGN KEY (position_id) REFERENCES new_schema.positions (position_id)
);

CREATE TABLE IF NOT EXISTS new_schema.employees_trains (
employee_id int NOT NULL,
train_id int NOT NULL,
assigned_date date DEFAULT current_date
); -- forgot to add UNIQUE constraint, let's do it now.
ALTER TABLE new_schema.employees_trains ADD CONSTRAINT composite_key UNIQUE (employee_id,train_id);

CREATE TABLE IF NOT EXISTS new_schema.infrastructure (
infrastructure_id serial PRIMARY KEY,
infrastructure_type varchar (15),
i_condition varchar(15) CHECK (condition IN ('Optimal','Suboptimal','Bad','Under repair','Inactive')),
last_inspected date CHECK (last_inspected < current_date),
inspected_by int,
CONSTRAINT fk_inspected FOREIGN KEY (inspected_by) REFERENCES new_schema.employee (employee_id)
);



CREATE TABLE IF NOT EXISTS new_schema.maintanence (
maintanence_id serial,
infrastructure_id int NOT NULL,
employee_id int NOT NULL,
start_date date,
end_date date CHECK (end_date>start_date),
m_cost decimal CHECK (m_cost>0),
CONSTRAINT fk_infrastructure FOREIGN KEY (infrastructure_id) REFERENCES new_schema.infrastructure(infrastructure_id),
CONSTRAINT fk_employee FOREIGN KEY (employee_id) REFERENCES new_schema.employee (employee_id)
);

CREATE TABLE IF NOT EXISTS new_schema.passengers (
social_number text PRIMARY KEY,
first_name varchar (15),
last_name varchar (20),
birthday date CHECK (birthday BETWEEN '1900-01-01' AND current_date),
gender varchar (6) CHECK (gender IN ('Male','Female'))

);

CREATE TABLE IF NOT EXISTS new_schema.tickets(
ticket_type_id serial PRIMARY KEY,
tt_name varchar (15) UNIQUE,
price decimal CHECK (price>0),
longevity smallint CHECK (longevity>0),
discount decimal CHECK (discount BETWEEN 0 AND 99)
);

CREATE TABLE IF NOT EXISTS new_schema.sales(
sale_id serial PRIMARY KEY,
ticket_type_id smallint NOT NULL,
sale_date date,
social_number text NOT NULL,
sale_location smallint NOT NULL,
CONSTRAINT FK_type_id FOREIGN KEY (ticket_type_id) REFERENCES new_schema.tickets(ticket_type_id),
CONSTRAINT FK_soial_number FOREIGN KEY (social_number) REFERENCES new_schema.passengers(social_number),
CONSTRAINT FK_LOCATION FOREIGN KEY (sale_location) REFERENCES new_schema.stations(station_id)
); --forgot to add UNIQUE constraint here, let's do it now
ALTER TABLE  new_schema.sales ADD CONSTRAINT saleun UNIQUE (social_number,sale_date);

--add 'record_ts' field to each table using ALTER TABLE statements, set the default value to current_date as instructed by the 8th note in task.
ALTER TABLE new_schema.employee ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.employees_trains ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.infrastructe ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.lines ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.maintanence ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.positions ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.passengers ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.sales ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.schedules ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.stations ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.stations_lines ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.tickets ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;

ALTER TABLE new_schema.trains ADD COLUMN record_ts DATE NOT NULL
DEFAULT current_date;


--insert two values in each table
INSERT INTO new_schema.stations (s_name,s_location,status) VALUES
('State University', 'Vaja-Pshavela ave. 99', 'Active'),
('Delisi','Vaja-Pshavela ave. 50', 'Active')
ON CONFLICT (s_name) DO NOTHING;

INSERT INTO new_schema.lines (l_name,route_description,frequency) VALUES
('main line','goes from gldani to varketili',10),
('saburtalo line','carries students to uni',10)
ON CONFLICT (l_name) DO NOTHING;

INSERT INTO new_schema.stations_lines (station_id,line_id,position_in_line) VALUES
(
 (SELECT station_id FROM new_schema.stations WHERE UPPER(s_name)='STATE UNIVERSITY'), 
 (SELECT line_id FROM  new_schema.lines WHERE UPPER (l_name)='SABURTALO LINE'),
 7
),
(
 (SELECT station_id FROM new_schema.stations WHERE UPPER(s_name)='DELISI'),
 (SELECT line_id FROM  new_schema.lines WHERE UPPER (l_name)='SABURTALO LINE'),
 5
)
ON CONFLICT (station_id,line_id) DO NOTHING;

INSERT INTO new_schema.schedules (departure_station, arrival_station, departure_time,arrival_time) values
(
(SELECT station_id FROM new_schema.stations WHERE UPPER(s_name)='STATE UNIVERSITY'),
(SELECT station_id FROM new_schema.stations WHERE UPPER(s_name)='DELISI'),
'20:00',
'21:00'
),
(
(SELECT station_id FROM new_schema.stations WHERE UPPER(s_name)='DELISI'),
(SELECT station_id FROM new_schema.stations WHERE UPPER(s_name)='STATE UNIVERSITY'),
'18:00',
'19:00'
)
ON CONFLICT (departure_time,departure_station) DO NOTHING;

INSERT INTO new_schema.trains (line_id,capacity,manufactured,status,schedule_id) VALUES
(
 (SELECT line_id FROM  new_schema.lines WHERE UPPER (l_name)='SABURTALO LINE'),
 100,
 2010,
 'Employed',
 1
),
((SELECT line_id FROM  new_schema.lines WHERE UPPER (l_name)='SABURTALO LINE'),
 150,
 2020,
 'Employed',
 2
);

INSERT INTO new_schema.positions (position_name,position_description) values 
( 'Driver', 'Drives trains'),
('Mechanic', 'Fixes trains')
ON CONFLICT (position_name) DO NOTHING;

INSERT INTO new_schema.employee (first_name,last_name,position_id,salary,gender)
SELECT 'Giorgi', 'Giorgadze', (SELECT position_id FROM new_schema.positions WHERE UPPER (POSITION_NAME)='DRIVER'),2500,'Male'
WHERE NOT EXISTS (
SELECT 1 FROM new_schema.employee WHERE UPPER (first_name)='GIORGI' AND UPPER (last_name)='GIORGADZE' AND 
position_id=(SELECT position_id FROM new_schema.positions WHERE UPPER (POSITION_NAME)='DRIVER')
);

INSERT INTO new_schema.employee (first_name,last_name,position_id,salary,gender)
SELECT 'Bondo', 'Sigua', (SELECT position_id FROM new_schema.positions WHERE UPPER (POSITION_NAME)='MECHANIC'),2000,'Male'
WHERE NOT EXISTS (
SELECT 1 FROM new_schema.employee WHERE UPPER (first_name)='BONDO' AND UPPER (last_name)='SIGUA' AND 
position_id=(SELECT position_id FROM new_schema.positions WHERE UPPER (POSITION_NAME)='MECHANIC')
);

INSERT INTO new_schema.employees_trains (employee_id,train_id, assigned_date) VALUES
((SELECT employee_id FROM new_schema.employee 
WHERE UPPER(first_name)='GIORGI' AND UPPER (last_name)='GIORGADZE'),1,'2024-06-07'
),
((SELECT employee_id FROM new_schema.employee 
WHERE UPPER(first_name)='BONDO' AND UPPER (last_name)='SIGUA'),2,'2025-06-07'

)
ON CONFLICT (employee_id,train_id) DO NOTHING;


INSERT INTO new_schema.infrastructure (infrastructure_type,infrastructure_condition,last_inspected, inspected_by) values
(
'Tunnel','Optimal', '2025-09-09', (
SELECT employee_id FROM new_schema.employee 
WHERE UPPER(first_name)='BONDO' AND UPPER (last_name)='SIGUA')
),
(
'Stairs','Suboptimal','2025-10-01',
(SELECT employee_id FROM new_schema.employee 
WHERE UPPER(first_name)='BONDO' AND UPPER (last_name)='SIGUA')
);


INSERT INTO new_schema.maintanence (infrastructure_id,employee_id,start_date,end_date,m_cost)
SELECT 1, (SELECT employee_id FROM new_schema.employee 
WHERE UPPER(first_name)='BONDO' AND UPPER (last_name)='SIGUA'),
'2024-01-01','2024-02-02',700 WHERE NOT EXISTS 
(SELECT 1 FROM new_schema.maintanence WHERE
infrastructure_id=1 AND start_date='2024-01-01'
);

INSERT INTO new_schema.maintanence (infrastructure_id,employee_id,start_date,end_date,m_cost)
SELECT 2, (SELECT employee_id FROM new_schema.employee 
WHERE UPPER(first_name)='BONDO' AND UPPER (last_name)='SIGUA'),
'2025-01-01','2025-02-02',100 WHERE NOT EXISTS 
(SELECT 1 FROM new_schema.maintanence WHERE
infrastructure_id=2 AND start_date='2025-01-01'
);

INSERT INTO new_schema.passengers (social_number,first_name,last_name,birthday,gender) values
('123456789','Leila','Gvaradze','1980-03-03','Female'),
('999999999','Nanuli','Shramiani','1960-05-05','Female')
ON CONFLICT (social_number) DO NOTHING;

INSERT INTO new_schema.tickets (tt_name,price,longevity,discount) values
('Medium Ticket',5,1,0.5),
('Year Pass',50,12,0.6)
ON CONFLICT (tt_name) DO NOTHING;

INSERT INTO new_schema.sales (ticket_type_id,sale_date,social_number,sale_location) values
(
 (SELECT ticket_type_id FROM new_schema.tickets WHERE UPPER(tt_name)='YEAR PASS'),
 current_date,
 (SELECT social_number FROM new_schema.passengers WHERE UPPER (first_name)='LEILA' AND UPPER (last_name)='GVARADZE'),
 (SELECT station_id FROM  new_schema.stations WHERE UPPER (s_name)='DELISI')
),
(
 (SELECT ticket_type_id FROM new_schema.tickets WHERE UPPER(tt_name)='MEDIUM TICKET'),
 current_date,
 (SELECT social_number FROM new_schema.passengers WHERE UPPER (first_name)='NANULI' AND UPPER (last_name)='SHRAMIANI'),
 (SELECT station_id FROM  new_schema.stations WHERE UPPER (s_name)='STATE UNIVERSITY')

)
ON CONFLICT (social_number,sale_date) DO NOTHING;






