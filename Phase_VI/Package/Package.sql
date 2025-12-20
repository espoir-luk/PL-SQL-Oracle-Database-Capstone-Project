CREATE OR REPLACE PACKAGE PKG_FARM_MANAGEMENT AS
    -- Exceptions
    INVALID_FARM_DATA EXCEPTION;
    FARM_NOT_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(INVALID_FARM_DATA, -20001);
    PRAGMA EXCEPTION_INIT(FARM_NOT_FOUND, -20002);
    
    -- Constants
    DEFAULT_WATER_PER_HECTARE CONSTANT NUMBER := 10000;
    MAX_FARM_AREA CONSTANT NUMBER := 1000;
    
    -- Procedures (from earlier)
    PROCEDURE ADD_NEW_FARM (
        p_farm_name        IN  VARCHAR2,
        p_location         IN  VARCHAR2,
        p_crop_type_id     IN  NUMBER,
        p_contact_info     IN  VARCHAR2 DEFAULT NULL,
        p_total_area       IN  NUMBER   DEFAULT NULL,
        p_new_farm_id      OUT NUMBER,
        p_status_message   OUT VARCHAR2
    );
    
    PROCEDURE DEACTIVATE_FARM (
        p_farm_id        IN  NUMBER,
        p_reason         IN  VARCHAR2 DEFAULT 'Inactive',
        p_user_id        IN  NUMBER,
        p_success_flag   OUT VARCHAR2,
        p_message        OUT VARCHAR2
    );
    
    -- Functions (from earlier)
    FUNCTION F_CALCULATE_WATER_NEED (
        p_farm_id IN NUMBER
    ) RETURN NUMBER;
    
    FUNCTION GET_FARM_DETAILS (
        p_farm_id IN NUMBER
    ) RETURN VARCHAR2;
    
    -- New function in package
    FUNCTION GET_FARM_STATISTICS (
        p_farm_id IN NUMBER
    ) RETURN SYS_REFCURSOR;
    
    -- Public variable
    v_last_operation_date DATE;
    
END PKG_FARM_MANAGEMENT;
/




CREATE OR REPLACE PACKAGE BODY PKG_FARM_MANAGEMENT AS
    
    -- Private variables (only accessible within package)
    v_farm_count NUMBER := 0;
    v_total_area NUMBER := 0;
    
    -- Private function (only accessible within package)
    FUNCTION VALIDATE_FARM_AREA (
        p_area IN NUMBER
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN (p_area IS NULL OR (p_area > 0 AND p_area <= MAX_FARM_AREA));
    END VALIDATE_FARM_AREA;
    
    -- Implementation of ADD_NEW_FARM (adapted from Procedure 1)
    PROCEDURE ADD_NEW_FARM (
        p_farm_name        IN  VARCHAR2,
        p_location         IN  VARCHAR2,
        p_crop_type_id     IN  NUMBER,
        p_contact_info     IN  VARCHAR2 DEFAULT NULL,
        p_total_area       IN  NUMBER   DEFAULT NULL,
        p_new_farm_id      OUT NUMBER,
        p_status_message   OUT VARCHAR2
    ) IS
        v_crop_exists NUMBER;
        v_duplicate_check NUMBER;
    BEGIN
        -- Validate inputs
        IF p_farm_name IS NULL OR p_location IS NULL OR p_crop_type_id IS NULL THEN
            RAISE INVALID_FARM_DATA;
        END IF;
        
        -- Validate area using private function
        IF NOT VALIDATE_FARM_AREA(p_total_area) THEN
            p_status_message := 'ERROR: Invalid farm area. Must be between 0 and ' || MAX_FARM_AREA;
            RETURN;
        END IF;
        
        -- Check crop exists
        SELECT COUNT(*) INTO v_crop_exists
        FROM crop_type
        WHERE crop_type_id = p_crop_type_id;
        
        IF v_crop_exists = 0 THEN
            p_status_message := 'ERROR: Invalid crop_type_id';
            RETURN;
        END IF;
        
        -- Check for duplicates
        SELECT COUNT(*) INTO v_duplicate_check
        FROM farm
        WHERE UPPER(farm_name) = UPPER(p_farm_name)
          AND UPPER(location) = UPPER(p_location);
        
        IF v_duplicate_check > 0 THEN
            p_status_message := 'ERROR: Farm with this name and location already exists';
            RETURN;
        END IF;
        
        -- Generate ID and insert
        SELECT seq_farm.NEXTVAL INTO p_new_farm_id FROM DUAL;
        
        INSERT INTO farm (
            farm_id, farm_name, location, crop_type_id,
            contact_info, total_area_hectares, registration_date, status
        ) VALUES (
            p_new_farm_id, p_farm_name, p_location, p_crop_type_id,
            p_contact_info, p_total_area, SYSDATE, 'ACTIVE'
        );
        
        -- Update package statistics
        v_farm_count := v_farm_count + 1;
        v_total_area := v_total_area + NVL(p_total_area, 0);
        v_last_operation_date := SYSDATE;
        
        p_status_message := 'SUCCESS: Farm added with ID: ' || p_new_farm_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN INVALID_FARM_DATA THEN
            p_status_message := 'ERROR: farm_name, location, and crop_type_id are required';
        WHEN OTHERS THEN
            ROLLBACK;
            p_status_message := 'ERROR: ' || SQLERRM;
    END ADD_NEW_FARM;
    
    -- New procedure: DEACTIVATE_FARM
    PROCEDURE DEACTIVATE_FARM (
        p_farm_id        IN  NUMBER,
        p_reason         IN  VARCHAR2 DEFAULT 'Inactive',
        p_user_id        IN  NUMBER,
        p_success_flag   OUT VARCHAR2,
        p_message        OUT VARCHAR2
    ) IS
        v_farm_exists NUMBER;
        v_current_status VARCHAR2(20);
    BEGIN
        -- Check farm exists
        SELECT COUNT(*), status
        INTO v_farm_exists, v_current_status
        FROM farm
        WHERE farm_id = p_farm_id;
        
        IF v_farm_exists = 0 THEN
            RAISE FARM_NOT_FOUND;
        END IF;
        
        IF v_current_status = 'INACTIVE' THEN
            p_message := 'WARNING: Farm is already inactive';
            p_success_flag := 'N';
            RETURN;
        END IF;
        
        -- Update farm status
        UPDATE farm
        SET status = 'INACTIVE'
        WHERE farm_id = p_farm_id;
        
        -- Create alert
        INSERT INTO alert_log (
            alert_id, farm_id, alert_type, alert_message,
            alert_timestamp, status, severity
        ) VALUES (
            seq_alert_log.NEXTVAL, p_farm_id, 'SCHEDULE_MISSED',
            'Farm deactivated. Reason: ' || p_reason,
            SYSTIMESTAMP, 'ACTIVE', 'MEDIUM'
        );
        
        v_last_operation_date := SYSDATE;
        p_success_flag := 'Y';
        p_message := 'SUCCESS: Farm deactivated';
        
        COMMIT;
        
    EXCEPTION
        WHEN FARM_NOT_FOUND THEN
            p_message := 'ERROR: Farm not found';
            p_success_flag := 'N';
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := 'ERROR: ' || SQLERRM;
            p_success_flag := 'N';
    END DEACTIVATE_FARM;
    
    -- Implementation of F_CALCULATE_WATER_NEED (from Function 1)
    FUNCTION F_CALCULATE_WATER_NEED (
        p_farm_id IN NUMBER
    ) RETURN NUMBER IS
        v_total_area        NUMBER;
        v_crop_type_id      NUMBER;
        v_optimal_moisture  NUMBER;
        v_water_need        NUMBER;
    BEGIN
        SELECT total_area_hectares, crop_type_id
        INTO v_total_area, v_crop_type_id
        FROM farm
        WHERE farm_id = p_farm_id
          AND status = 'ACTIVE';
        
        SELECT optimal_moisture
        INTO v_optimal_moisture
        FROM crop_type
        WHERE crop_type_id = v_crop_type_id;
        
        v_water_need := v_total_area * DEFAULT_WATER_PER_HECTARE * (v_optimal_moisture / 100);
        
        RETURN ROUND(v_water_need, 2);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1;
        WHEN OTHERS THEN
            RETURN -99;
    END F_CALCULATE_WATER_NEED;
    
    -- New function: GET_FARM_DETAILS
    FUNCTION GET_FARM_DETAILS (
        p_farm_id IN NUMBER
    ) RETURN VARCHAR2 IS
        v_details VARCHAR2(500);
    BEGIN
        SELECT 'Farm: ' || f.farm_name || 
               ' | Location: ' || f.location || 
               ' | Crop: ' || c.crop_name || 
               ' | Area: ' || f.total_area_hectares || ' ha' || 
               ' | Status: ' || f.status
        INTO v_details
        FROM farm f
        JOIN crop_type c ON f.crop_type_id = c.crop_type_id
        WHERE f.farm_id = p_farm_id;
        
        RETURN v_details;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Farm not found';
        WHEN OTHERS THEN
            RETURN 'Error retrieving details';
    END GET_FARM_DETAILS;
    
    -- New function: GET_FARM_STATISTICS (returns ref cursor)
    FUNCTION GET_FARM_STATISTICS (
        p_farm_id IN NUMBER
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                f.farm_id,
                f.farm_name,
                f.status,
                COUNT(s.sensor_id) as sensor_count,
                COUNT(CASE WHEN s.status = 'ACTIVE' THEN 1 END) as active_sensors,
                COUNT(i.inventory_id) as inventory_items,
                SUM(i.current_quantity) as total_inventory,
                COUNT(a.alert_id) as active_alerts
            FROM farm f
            LEFT JOIN sensor s ON f.farm_id = s.farm_id
            LEFT JOIN inventory i ON f.farm_id = i.farm_id
            LEFT JOIN alert_log a ON f.farm_id = a.farm_id AND a.status = 'ACTIVE'
            WHERE f.farm_id = p_farm_id
            GROUP BY f.farm_id, f.farm_name, f.status;
        
        RETURN v_cursor;
    END GET_FARM_STATISTICS;
    
    -- Package initialization (runs once when package is first called)
    BEGIN
        -- Initialize package variables
        SELECT COUNT(*), SUM(NVL(total_area_hectares, 0))
        INTO v_farm_count, v_total_area
        FROM farm
        WHERE status = 'ACTIVE';
        
        v_last_operation_date := SYSDATE;
        
        DBMS_OUTPUT.PUT_LINE('PKG_FARM_MANAGEMENT initialized. Active farms: ' || v_farm_count);
        
END PKG_FARM_MANAGEMENT;
/




-- Test the package after fixing
SET SERVEROUTPUT ON;

DECLARE
    v_new_id NUMBER;
    v_message VARCHAR2(500);
    v_details VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TESTING FIXED PKG_FARM_MANAGEMENT ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 1: Package function - GET_FARM_DETAILS
    v_details := PKG_FARM_MANAGEMENT.GET_FARM_DETAILS(1);
    DBMS_OUTPUT.PUT_LINE('1. GET_FARM_DETAILS:');
    DBMS_OUTPUT.PUT_LINE('   ' || v_details);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 2: Package function - F_CALCULATE_WATER_NEED
    DBMS_OUTPUT.PUT_LINE('2. F_CALCULATE_WATER_NEED:');
    DBMS_OUTPUT.PUT_LINE('   Result: ' || PKG_FARM_MANAGEMENT.F_CALCULATE_WATER_NEED(1));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 3: Package procedure - ADD_NEW_FARM (simple test)
    DBMS_OUTPUT.PUT_LINE('3. ADD_NEW_FARM:');
    PKG_FARM_MANAGEMENT.ADD_NEW_FARM(
        p_farm_name    => 'Test Package Farm',
        p_location     => 'Package Test Location',
        p_crop_type_id => 1002,
        p_new_farm_id  => v_new_id,
        p_status_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('   ' || v_message);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
