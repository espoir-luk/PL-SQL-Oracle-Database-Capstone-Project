-- ============================================
-- TRIGGER: TRG_INVENTORY_RESTRICTION
-- Enforces business rule on INVENTORY table
-- ============================================
CREATE OR REPLACE TRIGGER TRG_INVENTORY_RESTRICTION
BEFORE INSERT OR UPDATE OR DELETE ON INVENTORY
FOR EACH ROW
DECLARE
    v_status    VARCHAR2(50);
    v_audit_id  NUMBER;
    v_action    VARCHAR2(20);
BEGIN
    -- Determine action
    v_action := CASE 
        WHEN INSERTING THEN 'INSERT'
        WHEN UPDATING THEN 'UPDATE'
        WHEN DELETING THEN 'DELETE'
    END;
    
    -- Check restriction
    v_status := CHECK_RESTRICTION_PERIOD();
    
    -- Log attempt
    v_audit_id := LOG_AUDIT_TRAIL(
        p_table_name  => 'INVENTORY',
        p_action_type => v_action,
        p_user_id     => 0,
        p_record_id   => CASE 
            WHEN INSERTING THEN TO_CHAR(:NEW.INVENTORY_ID)
            ELSE TO_CHAR(:OLD.INVENTORY_ID)
        END
    );
    
    -- Apply restriction
    IF v_status != 'ALLOWED' THEN
        RAISE_APPLICATION_ERROR(-20011, 
            'INVENTORY ' || v_action || ' blocked. Reason: ' || v_status);
    END IF;
END;
/
