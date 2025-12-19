```sql

-- Phase IV: Tablespace Creation
-- Run in: THU_27678_ESPOIR_AGRIDPTIMA_DB

ALTER SESSION SET CONTAINER = THU_27678_ESPOIR_AGRIDPTIMA_DB;

-- Data tablespace
CREATE TABLESPACE agrioptima_data
DATAFILE 'agrioptima_data01.dbf' SIZE 500M AUTOEXTEND ON;

-- Index tablespace  
CREATE TABLESPACE agrioptima_idx
DATAFILE 'agrioptima_idx01.dbf' SIZE 300M AUTOEXTEND ON;

-- Temporary tablespace
CREATE TEMPORARY TABLESPACE agrioptima_temp
TEMPFILE 'agrioptima_temp01.dbf' SIZE 200M AUTOEXTEND ON;

```
