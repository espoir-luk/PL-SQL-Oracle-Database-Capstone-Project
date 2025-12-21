-- ============================================
-- TRIGGER: TRG_FARM_RESTRICTION
-- Enforces business rule on FARM table
-- ============================================
CREATE OR REPLACE TRIGGER TRG_FARM_RESTRICTION
BEFORE INSERT OR UPDATE OR DELETE ON FARM
FOR EACH ROW
DECLARE
    v_status    VARCHAR2(50);
    v_audit_id  NUMBER;
    v_action    VARCHAR2(20);
    v_record_id VARCHAR2(50);
BEGIN
    -- Determine action type
    v_action := CASE 
        WHEN INSERTING THEN 'INSERT'
        WHEN UPDATING THEN 'UPDATE'
        WHEN DELETING THEN 'DELETE'
    END;
    
    -- Get record ID
    v_record_id := CASE 
        WHEN INSERTING THEN TO_CHAR(:NEW.FARM_ID)
        ELSE TO_CHAR(:OLD.FARM_ID)
    END;
    
    -- Check restriction
    v_status := CHECK_RESTRICTION_PERIOD();
    
    -- Log attempt
    v_audit_id := LOG_AUDIT_TRAIL(
        p_table_name  => 'FARM',
        p_action_type => v_action,
        p_user_id     => 0,
        p_record_id   => v_record_id,
        p_old_values  => CASE WHEN UPDATING OR DELETING THEN 
                           TO_CLOB('OLD: Farm_ID=' || :OLD.FARM_ID || ', Name=' || :OLD.FARM_NAME) 
                         END,
        p_new_value   => CASE WHEN INSERTING OR UPDATING THEN 
                           TO_CLOB('NEW: Farm_ID=' || :NEW.FARM_ID || ', Name=' || :NEW.FARM_NAME) 
                         END
    );
    
    -- Apply restriction
    IF v_status != 'ALLOWED' THEN
        RAISE_APPLICATION_ERROR(-20010, 
            'FARM ' || v_action || ' blocked. Reason: ' || v_status || 
            '. Audit ID: ' || v_audit_id);
    END IF;
END;
/
