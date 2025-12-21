-- ============================================
-- FUNCTION: LOG_AUDIT_TRAIL
-- Purpose: Logs DML actions to AUDIT_LOG table
-- ============================================
CREATE OR REPLACE FUNCTION LOG_AUDIT_TRAIL(
    p_table_name      IN VARCHAR2,
    p_action_type     IN VARCHAR2,
    p_user_id         IN NUMBER,
    p_record_id       IN VARCHAR2 DEFAULT NULL,
    p_old_values      IN CLOB DEFAULT NULL,
    p_new_value       IN CLOB DEFAULT NULL,
    p_ip_address      IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER 
IS
    v_audit_id NUMBER;
BEGIN
    -- Validate action type
    IF p_action_type NOT IN ('INSERT', 'UPDATE', 'DELETE') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid action type');
    END IF;
    
    -- Get next sequence value
    SELECT AUDIT_LOG_SEQ.NEXTVAL INTO v_audit_id FROM DUAL;
    
    -- Insert into audit log
    INSERT INTO AUDIT_LOG (
        AUDIT_ID,
        TABLE_NAME,
        ACTION_TYPE,
        ACTION_TIMESTAMP,
        USER_ID,
        RECORD_ID,
        OLD_VALUES,
        NEW_VALUE,
        IP_ADDRESS
    ) VALUES (
        v_audit_id,
        p_table_name,
        p_action_type,
        SYSTIMESTAMP,
        p_user_id,
        p_record_id,
        p_old_values,
        p_new_value,
        p_ip_address
    );
    
    RETURN v_audit_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END LOG_AUDIT_TRAIL;
/
