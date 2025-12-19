```sql

-- Phase IV: Privilege Granting
-- Run in: THU_27678_ESPOIR_AGRIDPTIMA_DB

-- Grant DBA role (Super Admin)
GRANT DBA TO rukundo WITH ADMIN OPTION;

-- Grant additional privileges
GRANT CONNECT, RESOURCE TO rukundo;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, 
      CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE,
      CREATE USER, DROP USER TO rukundo;

```
