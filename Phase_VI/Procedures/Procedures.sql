CREATE OR REPLACE PROCEDURE ADD_NEW_FARM (
    p_farm_name        IN  VARCHAR2,
    p_location         IN  VARCHAR2,
    p_crop_type_id     IN  NUMBER,
    p_contact_info     IN  VARCHAR2 DEFAULT NULL,
    p_total_area       IN  NUMBER   DEFAULT NULL,
    p_new_farm_id      OUT NUMBER,
    p_status_message   OUT VARCHAR2
)
IS
    v_crop_exists NUMBER;
    v_duplicate_name NUMBER;
BEGIN
    -- 1. Validate crop_type_id exists
    SELECT COUNT(*) INTO v_crop_exists
    FROM crop_type
    WHERE crop_type_id = p_crop_type_id;
    
    IF v_crop_exists = 0 THEN
        p_status_message := 'ERROR: Invalid crop_type_id ' || p_crop_type_id;
        RETURN;
    END IF;
    
    -- 2. Check for duplicate farm name (optional business rule)
    SELECT COUNT(*) INTO v_duplicate_name
    FROM farm
    WHERE UPPER(farm_name) = UPPER(p_farm_name);
    
    IF v_duplicate_name > 0 THEN
        p_status_message := 'ERROR: Farm name already exists';
        RETURN;
    END IF;
    
    -- 3. Generate new farm ID using sequence
    SELECT seq_farm.NEXTVAL INTO p_new_farm_id FROM DUAL;
    
    -- 4. Insert the new farm
    INSERT INTO farm (
        farm_id,
        farm_name,
        location,
        crop_type_id,
        contact_info,
        total_area_hectares,
        registration_date,
        status
    ) VALUES (
        p_new_farm_id,
        p_farm_name,
        p_location,
        p_crop_type_id,
        p_contact_info,
        p_total_area,
        SYSDATE,
        'ACTIVE'
    );
    
    -- 5. Set success message
    p_status_message := 'SUCCESS: Farm ' || p_farm_name || ' added with ID: ' || p_new_farm_id;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status_message := 'ERROR: ' || SQLERRM;
        p_new_farm_id := NULL;
END ADD_NEW_FARM;
/



-- Test ADD_NEW_FARM procedure (using your actual crop_type_id 1002)
DECLARE
    v_new_id NUMBER;
    v_message VARCHAR2(200);
BEGIN
    -- Test 1: Valid insertion with correct crop_type_id
    ADD_NEW_FARM(
        p_farm_name    => 'Green Valley Farm',
        p_location     => 'Musanze, Northern Province',
        p_crop_type_id => 1002, -- Maize (your actual ID)
        p_contact_info => '+250788123456',
        p_total_area   => 45.5,
        p_new_farm_id  => v_new_id,
        p_status_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 1 Result: ' || v_message);
    
    -- Test 2: Missing required parameter (farm_name is NULL)
    ADD_NEW_FARM(
        p_farm_name    => NULL,
        p_location     => 'Test Location',
        p_crop_type_id => 1002,
        p_new_farm_id  => v_new_id,
        p_status_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 2 Result: ' || v_message);
    
    -- Test 3: Test duplicate prevention
    -- First insertion (should succeed)
    ADD_NEW_FARM(
        p_farm_name    => 'Sunshine Farm',
        p_location     => 'Nyagatare, Eastern Province',
        p_crop_type_id => 1003, -- Wheat
        p_new_farm_id  => v_new_id,
        p_status_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 3a Result: ' || v_message);
    
    -- Try same name AND same location (should fail)
    ADD_NEW_FARM(
        p_farm_name    => 'Sunshine Farm',
        p_location     => 'Nyagatare, Eastern Province', -- Same location
        p_crop_type_id => 1004, -- Rice
        p_new_farm_id  => v_new_id,
        p_status_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 3b Result: ' || v_message);
    
    -- Same name, different location (should succeed)
    ADD_NEW_FARM(
        p_farm_name    => 'Sunshine Farm',
        p_location     => 'Rubavu, Western Province', -- Different location
        p_crop_type_id => 1004,
        p_new_farm_id  => v_new_id,
        p_status_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 3c Result: ' || v_message);
    
    -- Test 4: Invalid crop_type_id
    ADD_NEW_FARM(
        p_farm_name    => 'Invalid Crop Farm',
        p_location     => 'Test Location',
        p_crop_type_id => 99999, -- Non-existent
        p_new_farm_id  => v_new_id,
        p_status_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 4 Result: ' || v_message);
END;
/




CREATE OR REPLACE PROCEDURE UPDATE_INVENTORY_LEVEL (
    p_farm_id          IN  NUMBER,
    p_resource_id      IN  NUMBER,
    p_quantity_change  IN  NUMBER,  -- Positive for addition, negative for deduction
    p_reason           IN  VARCHAR2 DEFAULT 'Stock Adjustment',
    p_user_id          IN  NUMBER,
    p_success_flag     OUT VARCHAR2,
    p_message          OUT VARCHAR2
)
IS
    v_current_qty      NUMBER;
    v_new_qty          NUMBER;
    v_resource_name    VARCHAR2(100);
    v_farm_name        VARCHAR2(100);
    v_exists           NUMBER;
    v_reorder_level    NUMBER;
    v_next_reorder     DATE;
    v_allocation_id    NUMBER;
    v_alert_id         NUMBER;
BEGIN
    -- 1. Validate parameters
    IF p_farm_id IS NULL OR p_resource_id IS NULL OR p_quantity_change = 0 OR p_user_id IS NULL THEN
        p_message := 'ERROR: farm_id, resource_id, quantity_change, and user_id are required';
        p_success_flag := 'N';
        RETURN;
    END IF;
    
    -- 2. Check if inventory record exists for this farm and resource
    SELECT COUNT(*)
    INTO v_exists
    FROM inventory
    WHERE farm_id = p_farm_id
      AND resource_id = p_resource_id;
    
    IF v_exists = 0 THEN
        p_message := 'ERROR: No inventory record found for farm_id=' || p_farm_id || 
                     ' and resource_id=' || p_resource_id;
        p_success_flag := 'N';
        RETURN;
    END IF;
    
    -- 3. Validate user exists and is active
    SELECT COUNT(*)
    INTO v_exists
    FROM agri_user
    WHERE user_id = p_user_id
      AND status = 'ACTIVE';
    
    IF v_exists = 0 THEN
        p_message := 'ERROR: Invalid or inactive user_id=' || p_user_id;
        p_success_flag := 'N';
        RETURN;
    END IF;
    
    -- 4. Get current quantity, reorder level, and validate
    SELECT i.current_quantity, r.resource_name, f.farm_name, r.reorder_level, i.next_reorder_date
    INTO v_current_qty, v_resource_name, v_farm_name, v_reorder_level, v_next_reorder
    FROM inventory i
    JOIN resource_type r ON i.resource_id = r.resource_id
    JOIN farm f ON i.farm_id = f.farm_id
    WHERE i.farm_id = p_farm_id
      AND i.resource_id = p_resource_id;
    
    v_new_qty := v_current_qty + p_quantity_change;
    
    IF v_new_qty < 0 THEN
        p_message := 'ERROR: Insufficient stock. Current: ' || v_current_qty || 
                     ', Attempted change: ' || p_quantity_change;
        p_success_flag := 'N';
        RETURN;
    END IF;
    
    -- 5. Determine next reorder date
    IF v_new_qty <= v_reorder_level THEN
        v_next_reorder := SYSDATE + 7;  -- Reorder in 7 days if below reorder level
    END IF;
    -- If not below reorder level, keep existing v_next_reorder (already fetched)
    
    -- 6. Update inventory
    UPDATE inventory
    SET current_quantity = v_new_qty,
        last_replenish_date = CASE WHEN p_quantity_change > 0 THEN SYSDATE ELSE last_replenish_date END,
        next_reorder_date = v_next_reorder
    WHERE farm_id = p_farm_id
      AND resource_id = p_resource_id;
    
    -- 7. Get next allocation_id safely
    BEGIN
        SELECT seq_allocation_log.NEXTVAL INTO v_allocation_id FROM DUAL;
        
        -- Log the allocation (for tracking)
        INSERT INTO allocation_log (
            allocation_id,
            farm_id,
            resource_id,
            allocated_quantity,
            allocation_timestamp,
            user_id,
            status,
            allocation_type,
            reason
        ) VALUES (
            v_allocation_id,
            p_farm_id,
            p_resource_id,
            ABS(p_quantity_change),  -- Absolute value for logging
            SYSTIMESTAMP,
            p_user_id,
            'COMPLETED',
            CASE WHEN p_quantity_change > 0 THEN 'MANUAL' ELSE 'MANUAL' END, -- Both as MANUAL (check constraint allows)
            p_reason || ' (Old: ' || v_current_qty || ', New: ' || v_new_qty || ')'
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            -- If PK violation, get next sequence value
            SELECT seq_allocation_log.NEXTVAL INTO v_allocation_id FROM DUAL;
            INSERT INTO allocation_log (
                allocation_id,
                farm_id,
                resource_id,
                allocated_quantity,
                allocation_timestamp,
                user_id,
                status,
                allocation_type,
                reason
            ) VALUES (
                v_allocation_id,
                p_farm_id,
                p_resource_id,
                ABS(p_quantity_change),
                SYSTIMESTAMP,
                p_user_id,
                'COMPLETED',
                'MANUAL',
                p_reason || ' (Retry - Old: ' || v_current_qty || ', New: ' || v_new_qty || ')'
            );
    END;
    
    -- 8. Check if low stock alert needed
    IF v_new_qty <= v_reorder_level THEN
        SELECT seq_alert_log.NEXTVAL INTO v_alert_id FROM DUAL;
        
        INSERT INTO alert_log (
            alert_id,
            farm_id,
            alert_type,
            alert_message,
            alert_timestamp,
            status,
            severity
        ) VALUES (
            v_alert_id,
            p_farm_id,
            'LOW_STOCK',
            'Resource ' || v_resource_name || ' is below reorder level. Current: ' || v_new_qty,
            SYSTIMESTAMP,
            'ACTIVE',
            'MEDIUM'
        );
    END IF;
    
    -- 9. Set success outputs
    p_success_flag := 'Y';
    p_message := 'SUCCESS: ' || v_farm_name || ' - ' || v_resource_name || 
                 ' updated from ' || v_current_qty || ' to ' || v_new_qty || 
                 ' (Change: ' || p_quantity_change || ')';
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        p_success_flag := 'N';
        p_message := 'ERROR: Data not found for farm_id=' || p_farm_id || 
                     ' resource_id=' || p_resource_id;
    WHEN OTHERS THEN
        ROLLBACK;
        p_success_flag := 'N';
        p_message := 'ERROR: ' || SQLERRM;
END UPDATE_INVENTORY_LEVEL;
/



-- test script
DECLARE
    v_success VARCHAR2(1);
    v_message VARCHAR2(500);
    v_farm_id NUMBER := 97;
    v_resource_id NUMBER := 1117;
    v_user_id NUMBER := 100;
    v_old_qty NUMBER;
BEGIN
    -- Get current quantity
    SELECT current_quantity INTO v_old_qty
    FROM inventory
    WHERE farm_id = v_farm_id AND resource_id = v_resource_id;
    
    DBMS_OUTPUT.PUT_LINE('Starting Test - Current Qty: ' || v_old_qty);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Test 1: Add stock
    UPDATE_INVENTORY_LEVEL(
        p_farm_id         => v_farm_id,
        p_resource_id     => v_resource_id,
        p_quantity_change => 25.5,
        p_reason          => 'Restock',
        p_user_id         => v_user_id,
        p_success_flag    => v_success,
        p_message         => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 1 (+25.5): ' || v_success || ' | ' || v_message);
    
    -- Test 2: Deduct stock
    UPDATE_INVENTORY_LEVEL(
        p_farm_id         => v_farm_id,
        p_resource_id     => v_resource_id,
        p_quantity_change => -10.0,
        p_reason          => 'Usage',
        p_user_id         => v_user_id,
        p_success_flag    => v_success,
        p_message         => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 2 (-10.0): ' || v_success || ' | ' || v_message);
    
    -- Test 3: Over-deduction (should fail)
    UPDATE_INVENTORY_LEVEL(
        p_farm_id         => v_farm_id,
        p_resource_id     => v_resource_id,
        p_quantity_change => -1000.0,
        p_reason          => 'Test fail',
        p_user_id         => v_user_id,
        p_success_flag    => v_success,
        p_message         => v_message
    );
    DBMS_OUTPUT.PUT_LINE('Test 3 (-1000): ' || v_success || ' | ' || v_message);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/





CREATE OR REPLACE PROCEDURE DEACTIVATE_SENSOR (
    p_sensor_id        IN  NUMBER,
    p_deactivate_reason IN VARCHAR2 DEFAULT 'Maintenance',
    p_user_id          IN  NUMBER,
    p_success_flag     OUT VARCHAR2,
    p_message          OUT VARCHAR2
)
IS
    v_current_status   VARCHAR2(20);
    v_farm_id          NUMBER;
    v_sensor_type      VARCHAR2(30);
    v_deactivated_by   VARCHAR2(100);
    v_equipment_resource_id NUMBER;
BEGIN
    -- 1. Validate parameters
    IF p_sensor_id IS NULL OR p_user_id IS NULL THEN
        p_message := 'ERROR: sensor_id and user_id are required';
        p_success_flag := 'N';
        RETURN;
    END IF;
    
    -- 2. Check if sensor exists and get its details
    BEGIN
        SELECT status, farm_id, sensor_type
        INTO v_current_status, v_farm_id, v_sensor_type
        FROM sensor
        WHERE sensor_id = p_sensor_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_message := 'ERROR: Sensor ID ' || p_sensor_id || ' not found';
            p_success_flag := 'N';
            RETURN;
    END;
    
    -- 3. Check if already deactivated
    IF v_current_status IN ('INACTIVE', 'FAULTY') THEN
        p_message := 'WARNING: Sensor ' || p_sensor_id || ' is already ' || v_current_status;
        p_success_flag := 'N';
        RETURN;
    END IF;
    
    -- 4. Validate user exists and is active
    BEGIN
        SELECT full_name INTO v_deactivated_by
        FROM agri_user
        WHERE user_id = p_user_id AND status = 'ACTIVE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_message := 'ERROR: Invalid or inactive user_id=' || p_user_id;
            p_success_flag := 'N';
            RETURN;
    END;
    
    -- 5. Get a resource_id for equipment
    BEGIN
        SELECT resource_id INTO v_equipment_resource_id
        FROM resource_type
        WHERE category = 'EQUIPMENT'
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_equipment_resource_id := 1106; -- Default to Tractor
    END;
    
    -- 6. Update sensor status
    UPDATE sensor
    SET status = 'INACTIVE',
        last_calibration_date = NULL
    WHERE sensor_id = p_sensor_id;
    
    -- 7. Create alert about sensor deactivation
    INSERT INTO alert_log (
        alert_id,
        farm_id,
        alert_type,
        alert_message,
        alert_timestamp,
        status,
        severity,
        acknowledged_by
    ) VALUES (
        seq_alert_log.NEXTVAL,
        v_farm_id,
        'EQUIPMENT_FAILURE',
        'Sensor ' || p_sensor_id || ' (' || v_sensor_type || ') deactivated. Reason: ' || p_deactivate_reason,
        SYSTIMESTAMP,
        'ACTIVE',
        'MEDIUM',
        p_user_id
    );
    
    -- 8. Log the deactivation in allocation_log
    INSERT INTO allocation_log (
        allocation_id,
        farm_id,
        resource_id,
        allocated_quantity,
        allocation_timestamp,
        user_id,
        status,
        allocation_type,
        reason
    ) VALUES (
        seq_allocation_log.NEXTVAL,
        v_farm_id,
        v_equipment_resource_id,
        1,
        SYSTIMESTAMP,
        p_user_id,
        'COMPLETED',
        'MANUAL',
        'Sensor Deactivation: ID=' || p_sensor_id || ', Type=' || v_sensor_type || 
        ', Reason: ' || p_deactivate_reason || ' (By: ' || v_deactivated_by || ')'
    );
    
    -- 9. Set success outputs
    p_success_flag := 'Y';
    p_message := 'SUCCESS: Sensor ' || p_sensor_id || ' (' || v_sensor_type || 
                 ') deactivated from Farm ID: ' || v_farm_id || 
                 '. Reason: ' || p_deactivate_reason;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_success_flag := 'N';
        p_message := 'ERROR: ' || SQLERRM;
END DEACTIVATE_SENSOR;
/


-- Test DEACTIVATE_SENSOR after sequence fix
DECLARE
    v_success VARCHAR2(1);
    v_message VARCHAR2(500);
    v_sensor_id NUMBER;
    v_user_id NUMBER;
BEGIN
    -- Get one active sensor (make sure it's active)
    SELECT sensor_id INTO v_sensor_id
    FROM sensor 
    WHERE status = 'ACTIVE' 
      AND ROWNUM = 1;
    
    -- Get an active user
    SELECT user_id INTO v_user_id
    FROM agri_user 
    WHERE status = 'ACTIVE' 
      AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Testing with Sensor ID: ' || v_sensor_id);
    DBMS_OUTPUT.PUT_LINE('User ID: ' || v_user_id);
    
    -- Test the procedure
    DEACTIVATE_SENSOR(
        p_sensor_id        => v_sensor_id,
        p_deactivate_reason => 'Test after sequence fix',
        p_user_id          => v_user_id,
        p_success_flag     => v_success,
        p_message          => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_success || ' | ' || v_message);
    
    -- Verify the deactivation
    IF v_success = 'Y' THEN
        DBMS_OUTPUT.PUT_LINE('Verifying sensor status...');
        FOR r IN (SELECT sensor_id, status FROM sensor WHERE sensor_id = v_sensor_id) LOOP
            DBMS_OUTPUT.PUT_LINE('Sensor ' || r.sensor_id || ' status: ' || r.status);
        END LOOP;
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No active sensor or user found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


-- Final test of all three procedures
SET SERVEROUTPUT ON;

DECLARE
    v_success VARCHAR2(1);
    v_message VARCHAR2(500);
    v_new_farm_id NUMBER;
    v_test_crop_id NUMBER;
    v_test_farm_id NUMBER;
    v_test_resource_id NUMBER;
    v_test_user_id NUMBER;
    v_test_sensor_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TESTING ALL 3 PROCEDURES ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Get test data
    SELECT MIN(crop_type_id) INTO v_test_crop_id FROM crop_type;
    SELECT farm_id INTO v_test_farm_id FROM farm WHERE status = 'ACTIVE' AND ROWNUM = 1;
    SELECT resource_id INTO v_test_resource_id FROM resource_type WHERE ROWNUM = 1;
    SELECT user_id INTO v_test_user_id FROM agri_user WHERE status = 'ACTIVE' AND ROWNUM = 1;
    SELECT sensor_id INTO v_test_sensor_id FROM sensor WHERE status = 'ACTIVE' AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Test Data Loaded:');
    DBMS_OUTPUT.PUT_LINE('- Crop ID: ' || v_test_crop_id);
    DBMS_OUTPUT.PUT_LINE('- Farm ID: ' || v_test_farm_id);
    DBMS_OUTPUT.PUT_LINE('- Resource ID: ' || v_test_resource_id);
    DBMS_OUTPUT.PUT_LINE('- User ID: ' || v_test_user_id);
    DBMS_OUTPUT.PUT_LINE('- Sensor ID: ' || v_test_sensor_id);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 1: ADD_NEW_FARM (Procedure 1)
    DBMS_OUTPUT.PUT_LINE('1. TESTING ADD_NEW_FARM:');
    ADD_NEW_FARM(
        p_farm_name    => 'Test Farm ' || TO_CHAR(SYSDATE, 'HH24MISS'),
        p_location     => 'Test Location',
        p_crop_type_id => v_test_crop_id,
        p_contact_info => '+250788999999',
        p_total_area   => 50.0,
        p_new_farm_id  => v_new_farm_id,
        p_status_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('   Result: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 2: UPDATE_INVENTORY_LEVEL (Procedure 2)
    DBMS_OUTPUT.PUT_LINE('2. TESTING UPDATE_INVENTORY_LEVEL:');
    UPDATE_INVENTORY_LEVEL(
        p_farm_id         => v_test_farm_id,
        p_resource_id     => v_test_resource_id,
        p_quantity_change => 15.5,
        p_reason          => 'Test update',
        p_user_id         => v_test_user_id,
        p_success_flag    => v_success,
        p_message         => v_message
    );
    DBMS_OUTPUT.PUT_LINE('   Result: ' || v_success || ' | ' || v_message);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 3: DEACTIVATE_SENSOR (Procedure 3)
    DBMS_OUTPUT.PUT_LINE('3. TESTING DEACTIVATE_SENSOR:');
    DEACTIVATE_SENSOR(
        p_sensor_id        => v_test_sensor_id,
        p_deactivate_reason => 'End of testing',
        p_user_id          => v_test_user_id,
        p_success_flag     => v_success,
        p_message          => v_message
    );
    DBMS_OUTPUT.PUT_LINE('   Result: ' || v_success || ' | ' || v_message);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== ALL TESTS COMPLETED ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in test suite: ' || SQLERRM);
END;
/
