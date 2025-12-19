```sql

-- Phase IV: Verification Script
-- Run in: THU_27678_ESPOIR_AGRIDPTIMA_DB

SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 50

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PHASE IV SETUP VERIFICATION ===');
    DBMS_OUTPUT.PUT_LINE('Database: THU_27678_ESPOIR_AGRIDPTIMA_DB');
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('=====================================');
END;
/

-- 1. Verify PDB
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS "Current PDB",
       SYS_CONTEXT('USERENV', 'DB_NAME') AS "Database Name"
FROM DUAL;

-- 2. Verify Tablespaces
SELECT tablespace_name, status, contents,
       ROUND((SELECT SUM(bytes)/1024/1024 
              FROM dba_data_files 
              WHERE tablespace_name = dt.tablespace_name), 2) as SIZE_MB
FROM dba_tablespaces dt
WHERE tablespace_name LIKE 'AGRIOPTIMA%'
ORDER BY tablespace_name;

-- 3. Verify User
SELECT username, account_status, 
       default_tablespace, temporary_tablespace,
       TO_CHAR(created, 'DD-MON-YYYY') as created
FROM dba_users
WHERE username = 'RUKUNDO';

-- 4. Verify Privileges
SELECT granted_role, admin_option
FROM dba_role_privs
WHERE grantee = 'RUKUNDO' AND granted_role = 'DBA';

-- 5. Test Admin Privilege
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Testing Admin Privilege...');
    EXECUTE IMMEDIATE 'CREATE USER phase4_verify IDENTIFIED BY test123';
    DBMS_OUTPUT.PUT_LINE('✓ CREATE USER successful');
    EXECUTE IMMEDIATE 'DROP USER phase4_verify';
    DBMS_OUTPUT.PUT_LINE('✓ DROP USER successful');
    DBMS_OUTPUT.PUT_LINE('✓ Admin privileges confirmed');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Admin test failed: ' || SQLERRM);
END;
/

```
