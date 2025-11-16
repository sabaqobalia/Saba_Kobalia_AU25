
1. Create table ‘table_to_delete’ and fill it with the following query:        --Query complete 00:00:23.444

CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x; -- generate_series() creates 10^7 rows of sequential numbers from 1 to 10000000 (10^7)


2. Lookup how much space this table consumes with the following query:        --total_bytes = 602415104

 SELECT *, pg_size_pretty(total_bytes) AS total,
                                    pg_size_pretty(index_bytes) AS INDEX,
                                    pg_size_pretty(toast_bytes) AS toast,
                                    pg_size_pretty(table_bytes) AS TABLE
FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
                               FROM (SELECT c.oid,nspname AS table_schema,
                                                               relname AS TABLE_NAME,
                                                              c.reltuples AS row_estimate,
                                                              pg_total_relation_size(c.oid) AS total_bytes,
                                                              pg_indexes_size(c.oid) AS index_bytes,
                                                              pg_total_relation_size(reltoastrelid) AS toast_bytes
                                              FROM pg_class c
                                              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                                              WHERE relkind = 'r'
                                              ) a
WHERE table_name LIKE '%table_to_delete%';


3. Issue the following DELETE operation on ‘table_to_delete’:

               DELETE FROM table_to_delete
               WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; -- removes 1/3 of all rows


      a) Note how much time it takes to perform this DELETE statement;     -- Query complete 00:00:18.853
      b) Lookup how much space this table consumes after previous DELETE;       --total_bytes = 602611712
      c) Perform the following command (if you're using DBeaver, press Ctrl+Shift+O to observe server output (VACUUM results)): 
          VACUUM FULL VERBOSE table_to_delete;     
      d) Check space consumption of the table once again and make conclusions;       --total_bytes = 401580032 so vacuum freed space that was unnecessarily used
      e) Recreate ‘table_to_delete’ table;         --First i had to drop this table before recreating it 

VACUUM FULL VERBOSE  table_to_delete;
--DROP TABLE table_to_delete;
/*
4. Issue the following TRUNCATE operation:

               TRUNCATE table_to_delete;

      a) Note how much time it takes to perform this TRUNCATE statement.      --Query complete 00:00:00.103
      b) Compare with previous results and make conclusion.     --truncate happens much faster then delete
      c) Check space consumption of the table once again and make conclusions;      --total_bytes = 8192, truncate frees significantly more space then delete, leaves only toast_bytes

5. Hand over your investigation's results to your trainer. The results must include:

      a) Space consumption of ‘table_to_delete’ table before and after each operation;
      b) Duration of each operation (DELETE, TRUNCATE)
	  
create table - Query complete 00:00:23.444
table size - total_bytes = 602415104
delete 1/3 - Query complete 00:00:18.853
size after that - total_bytes = 602611712
size after VACUUM - total_bytes = 401580032 , vacuum freed space that was unnecessarily used
truncate table - Query complete 00:00:00.103 , truncate happens much faster then delete
size  after truncate - total_bytes = 8192 , truncate frees significantly more space then delete, leaves only toast_bytes
