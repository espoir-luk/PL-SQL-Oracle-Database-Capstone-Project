-- ============================================
-- CREATE SEQUENCES for AgriOptima Enhanced BI
-- Phase V: Table Implementation
-- Student: [Your Name]
-- Student ID: [Your ID]
-- Date: December 19, 2024
-- ============================================

-- ============================================
-- 1. Sequence for CROP_TYPE table
-- ============================================
CREATE SEQUENCE seq_crop_type
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 2. Sequence for FARM table
-- ============================================
CREATE SEQUENCE seq_farm
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 3. Sequence for SENSOR table
-- ============================================
CREATE SEQUENCE seq_sensor
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 4. Sequence for SENSOR_READING table
-- ============================================
CREATE SEQUENCE seq_sensor_reading
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 5. Sequence for RESOURCE_TYPE table
-- ============================================
CREATE SEQUENCE seq_resource_type
    START WITH 100
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 6. Sequence for INVENTORY table
-- ============================================
CREATE SEQUENCE seq_inventory
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 7. Sequence for ALLOCATION_LOG table
-- ============================================
CREATE SEQUENCE seq_allocation_log
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 8. Sequence for ALERT_LOG table
-- ============================================
CREATE SEQUENCE seq_alert_log
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 9. Sequence for AGRI_USER table
-- ============================================
CREATE SEQUENCE seq_user
    START WITH 100
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- 10. Sequence for AUDIT_LOG table
-- Note: HOLIDAY table uses DATE as PK, no sequence needed
-- ============================================
CREATE SEQUENCE seq_audit_log
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================
-- Verification of Sequences
-- ============================================
DECLARE
    v_sequence_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_sequence_count
    FROM user_sequences
    WHERE sequence_name LIKE 'SEQ_%';
    
    DBMS_OUTPUT.PUT_LINE('Created ' || v_sequence_count || ' sequences:');
    DBMS_OUTPUT.PUT_LINE('1. seq_crop_type       - Starting at 1000');
    DBMS_OUTPUT.PUT_LINE('2. seq_farm            - Starting at 1000');
    DBMS_OUTPUT.PUT_LINE('3. seq_sensor          - Starting at 1000');
    DBMS_OUTPUT.PUT_LINE('4. seq_sensor_reading  - Starting at 1');
    DBMS_OUTPUT.PUT_LINE('5. seq_resource_type   - Starting at 100');
    DBMS_OUTPUT.PUT_LINE('6. seq_inventory       - Starting at 1');
    DBMS_OUTPUT.PUT_LINE('7. seq_allocation_log  - Starting at 1');
    DBMS_OUTPUT.PUT_LINE('8. seq_alert_log       - Starting at 1');
    DBMS_OUTPUT.PUT_LINE('9. seq_user            - Starting at 100');
    DBMS_OUTPUT.PUT_LINE('10. seq_audit_log      - Starting at 1');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error verifying sequences: ' || SQLERRM);
END;
/

-- ============================================
-- Optional: Create synonyms for easier access
-- ============================================
CREATE OR REPLACE SYNONYM seq_crop FOR seq_crop_type;
CREATE OR REPLACE SYNONYM seq_res FOR seq_resource_type;
CREATE OR REPLACE SYNONYM seq_alloc FOR seq_allocation_log;
CREATE OR REPLACE SYNONYM seq_alert FOR seq_alert_log;
CREATE OR REPLACE SYNONYM seq_audit FOR seq_audit_log;

DBMS_OUTPUT.PUT_LINE('All sequences created successfully.');
DBMS_OUTPUT.PUT_LINE('Note: HOLIDAY table uses DATE as primary key, no sequence required.');
