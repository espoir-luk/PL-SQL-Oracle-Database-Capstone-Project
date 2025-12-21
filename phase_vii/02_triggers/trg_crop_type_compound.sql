-- ============================================
-- COMPOUND TRIGGER: TRG_CROP_TYPE_COMPOUND
-- Demonstrates advanced trigger capabilities
-- ============================================
CREATE OR REPLACE TRIGGER TRG_CROP_TYPE_COMPOUND
FOR INSERT OR UPDATE OR DELETE ON CROP_TYPE
COMPOUND TRIGGER
    
    -- Declaration section
    TYPE t_audit_rec IS RECORD (
        action_type VARCHAR2(20),
        record_id   VARCHAR2(50),
        old_name    VARCHAR2(100),
        new_name    VARCHAR2(100)
    );
    
    TYPE t_audit_table IS TABLE OF t_audit_rec;
    v_audit_data t_audit_table := t_audit_table();
    
    -- BEFORE STATEMENT section
    BEFORE STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Starting bulk operation on CROP_TYPE');
    END BEFORE STATEMENT;
    
    -- BEFORE EACH ROW section
    BEFORE EACH ROW IS
    BEGIN
        -- Apply restriction per row
        IF CHECK_RESTRICTION_PERIOD() != 'ALLOWED' THEN
            RAISE_APPLICATION_ERROR(-20012, 
                'CROP_TYPE operation not allowed');
        END IF;
    END BEFORE EACH ROW;
    
    -- AFTER EACH ROW section
    AFTER EACH ROW IS
        v_rec t_audit_rec;
    BEGIN
        -- Collect audit data
        v_rec.record_id := CASE 
            WHEN INSERTING THEN TO_CHAR(:NEW.CROP_TYPE_ID)
            ELSE TO_CHAR(:OLD.CROP_TYPE_ID)
        END;
        
        v_rec.old_name := :OLD.CROP_NAME;
        v_rec.new_name := :NEW.CROP_NAME;
        
        v_rec.action_type := CASE 
            WHEN INSERTING THEN 'INSERT'
            WHEN UPDATING THEN 'UPDATE'
            WHEN DELETING THEN 'DELETE'
        END;
        
        v_audit_data.EXTEND;
        v_audit_data(v_audit_data.LAST) := v_rec;
    END AFTER EACH ROW;
    
    -- AFTER STATEMENT section
    AFTER STATEMENT IS
        v_audit_id NUMBER;
    BEGIN
        -- Bulk audit logging
        FOR i IN 1..v_audit_data.COUNT LOOP
            v_audit_id := LOG_AUDIT_TRAIL(
                p_table_name  => 'CROP_TYPE',
                p_action_type => v_audit_data(i).action_type,
                p_user_id     => 0,
                p_record_id   => v_audit_data(i).record_id
            );
            DBMS_OUTPUT.PUT_LINE('Logged ' || v_audit_data(i).action_type || 
                               ' on ID ' || v_audit_data(i).record_id);
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Completed bulk operation. Records: ' || v_audit_data.COUNT);
    END AFTER STATEMENT;
    
END TRG_CROP_TYPE_COMPOUND;
/
