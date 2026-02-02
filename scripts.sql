CREATE SCHEMA IF NOT EXISTS SA_SOURCE1;
CREATE SCHEMA IF NOT EXISTS SA_SOURCE2;
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER csv_server
FOREIGN DATA WRAPPER file_fdw;


--Create foreign tables for raw data:

CREATE FOREIGN TABLE SA_SOURCE1.ext_source1 (
    transaction_id        VARCHAR,
    store_name            VARCHAR,
    city                  VARCHAR,
    transaction_date      TIMESTAMP,
    cashier_id            VARCHAR,
    items_count           INTEGER,
    total_amount_ngn      NUMERIC,
    payment_method        VARCHAR,
    discount_applied      BOOLEAN,
    loyalty_points_earned INTEGER,
    receipt_number        VARCHAR
)
SERVER csv_server
OPTIONS (
    filename 'C:/csv/source1.csv',
    format 'csv',
    header 'true'
);


CREATE FOREIGN TABLE SA_SOURCE2.ext_source2 (
    transaction_id        VARCHAR,
    store_name            VARCHAR,
    city                  VARCHAR,
    transaction_date      TIMESTAMP,
    cashier_id            VARCHAR,
    items_count           INTEGER,
    total_amount_ngn      NUMERIC,
    payment_method        VARCHAR,
    discount_applied      BOOLEAN,
    loyalty_points_earned INTEGER,
    receipt_number        VARCHAR
)
SERVER csv_server
OPTIONS (
    filename 'C:/csv/source2.csv',
    format 'csv',
    header 'true'
);


--create source tables

CREATE TABLE SA_SOURCE1.src_source1 (
    transaction_id        VARCHAR NOT NULL,
    store_name            VARCHAR NOT NULL,
    city                  VARCHAR NOT NULL,
    transaction_date      TIMESTAMP NOT NULL,
    cashier_id            VARCHAR NOT NULL,
    items_count           INTEGER NOT NULL,
    total_amount_ngn      NUMERIC(12,2) NOT NULL,
    payment_method        VARCHAR NOT NULL,
    discount_applied      BOOLEAN NOT NULL,
    loyalty_points_earned INTEGER NOT NULL,
    receipt_number        VARCHAR NOT NULL,
    source_system         VARCHAR NOT NULL,
    load_ts               TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE SA_SOURCE2.src_source2 (
    transaction_id        VARCHAR NOT NULL,
    store_name            VARCHAR NOT NULL,
    city                  VARCHAR NOT NULL,
    transaction_date      TIMESTAMP NOT NULL,
    cashier_id            VARCHAR NOT NULL,
    items_count           INTEGER NOT NULL,
    total_amount_ngn      NUMERIC(12,2) NOT NULL,
    payment_method        VARCHAR NOT NULL,
    discount_applied      BOOLEAN NOT NULL,
    loyalty_points_earned INTEGER NOT NULL,
    receipt_number        VARCHAR NOT NULL,
    source_system         VARCHAR NOT NULL,
    load_ts               TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


--insert into sources

INSERT INTO SA_SOURCE1.src_source1 (
    transaction_id,
    store_name,
    city,
    transaction_date,
    cashier_id,
    items_count,
    total_amount_ngn,
    payment_method,
    discount_applied,
    loyalty_points_earned,
    receipt_number,
    source_system
)
SELECT
    transaction_id,
    store_name,
    city,
    transaction_date,
    cashier_id,
    items_count,
    total_amount_ngn,
    payment_method,
    discount_applied,
    loyalty_points_earned,
    receipt_number,
    'SOURCE1_CSV'
FROM SA_SOURCE1.ext_source1;

INSERT INTO SA_SOURCE2.src_source2 (
    transaction_id,
    store_name,
    city,
    transaction_date,
    cashier_id,
    items_count,
    total_amount_ngn,
    payment_method,
    discount_applied,
    loyalty_points_earned,
    receipt_number,
    source_system
)
SELECT
    transaction_id,
    store_name,
    city,
    transaction_date,
    cashier_id,
    items_count,
    total_amount_ngn,
    payment_method,
    discount_applied,
    loyalty_points_earned,
    receipt_number,
    'SOURCE2_CSV'
FROM SA_SOURCE2.ext_source2;

