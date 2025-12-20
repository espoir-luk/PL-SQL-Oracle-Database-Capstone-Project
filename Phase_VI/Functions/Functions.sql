CREATE OR REPLACE FUNCTION F_CALCULATE_WATER_NEED (
    p_farm_id IN NUMBER
) RETURN NUMBER
IS
    v_total_area        NUMBER;
    v_crop_type_id      NUMBER;
    v_optimal_moisture  NUMBER;
    v_water_per_hectare NUMBER := 10000; -- Default: 10,000 liters per hectare
    v_water_need        NUMBER;
BEGIN
    -- Get farm area and crop type
    SELECT total_area_hectares, crop_type_id
    INTO v_total_area, v_crop_type_id
    FROM farm
    WHERE farm_id = p_farm_id
      AND status = 'ACTIVE';
    
    -- Get optimal moisture for the crop
    SELECT optimal_moisture
    INTO v_optimal_moisture
    FROM crop_type
    WHERE crop_type_id = v_crop_type_id;
    
    -- Calculate water need: area * base water * (moisture % / 100)
    -- More moisture need = more water required
    v_water_need := v_total_area * v_water_per_hectare * (v_optimal_moisture / 100);
    
    RETURN ROUND(v_water_need, 2);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1; -- Error code
    WHEN OTHERS THEN
        RETURN -99; -- General error
END F_CALCULATE_WATER_NEED;
/

-- Test F_CALCULATE_WATER_NEED
DECLARE
    v_water_need NUMBER;
    v_test_farm_id NUMBER;
BEGIN
    -- Get an active farm
    SELECT farm_id INTO v_test_farm_id
    FROM farm 
    WHERE status = 'ACTIVE' 
      AND total_area_hectares IS NOT NULL
      AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Testing Function 1: F_CALCULATE_WATER_NEED');
    DBMS_OUTPUT.PUT_LINE('Test Farm ID: ' || v_test_farm_id);
    
    -- Call the function
    v_water_need := F_CALCULATE_WATER_NEED(p_farm_id => v_test_farm_id);
    
    IF v_water_need = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Result: Farm or crop data not found');
    ELSIF v_water_need = -99 THEN
        DBMS_OUTPUT.PUT_LINE('Result: Calculation error');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Result: Water need = ' || v_water_need || ' liters');
        DBMS_OUTPUT.PUT_LINE('         = ' || ROUND(v_water_need/1000, 2) || ' m³');
    END IF;
    
    -- Test in SQL query
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Testing function in SQL query:');
    FOR r IN (
        SELECT farm_id, farm_name, total_area_hectares,
               F_CALCULATE_WATER_NEED(farm_id) as water_need_liters
        FROM farm 
        WHERE status = 'ACTIVE' 
          AND ROWNUM <= 3
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(r.farm_name || ' (ID: ' || r.farm_id || 
                           ', Area: ' || r.total_area_hectares || ' ha) = ' || 
                           r.water_need_liters || ' liters');
    END LOOP;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No active farm found for testing');
END;
/


  
  CREATE OR REPLACE FUNCTION F_GET_RESOURCE_STATUS (
    p_farm_id     IN NUMBER,
    p_resource_id IN NUMBER
) RETURN VARCHAR2
IS
    v_current_qty   NUMBER;
    v_reorder_level NUMBER;
    v_resource_name VARCHAR2(100);
    v_status        VARCHAR2(50);
BEGIN
    -- Get current inventory and reorder level
    SELECT i.current_quantity, r.reorder_level, r.resource_name
    INTO v_current_qty, v_reorder_level, v_resource_name
    FROM inventory i
    JOIN resource_type r ON i.resource_id = r.resource_id
    WHERE i.farm_id = p_farm_id
      AND i.resource_id = p_resource_id;
    
    -- Determine status
    IF v_current_qty <= 0 THEN
        v_status := 'OUT_OF_STOCK';
    ELSIF v_current_qty <= v_reorder_level THEN
        v_status := 'LOW_STOCK';
    ELSIF v_current_qty <= (v_reorder_level * 2) THEN
        v_status := 'ADEQUATE';
    ELSE
        v_status := 'GOOD_STOCK';
    END IF;
    
    RETURN v_status;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT_MONITORED'; -- No inventory record
    WHEN OTHERS THEN
        RETURN 'ERROR';
END F_GET_RESOURCE_STATUS;
/

-- Test F_GET_RESOURCE_STATUS
DECLARE
    v_status VARCHAR2(50);
    v_farm_id NUMBER;
    v_resource_id NUMBER;
BEGIN
    -- Get test inventory data
    SELECT i.farm_id, i.resource_id
    INTO v_farm_id, v_resource_id
    FROM inventory i
    WHERE i.current_quantity > 0
      AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Testing Function 2: F_GET_RESOURCE_STATUS');
    DBMS_OUTPUT.PUT_LINE('Farm ID: ' || v_farm_id || ', Resource ID: ' || v_resource_id);
    
    -- Call the function
    v_status := F_GET_RESOURCE_STATUS(
        p_farm_id => v_farm_id,
        p_resource_id => v_resource_id
    );
    
    DBMS_OUTPUT.PUT_LINE('Result: Resource Status = ' || v_status);
    
    -- Test multiple resources
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Status for multiple resources:');
    FOR r IN (
        SELECT i.farm_id, r.resource_name, i.current_quantity,
               F_GET_RESOURCE_STATUS(i.farm_id, i.resource_id) as status
        FROM inventory i
        JOIN resource_type r ON i.resource_id = r.resource_id
        WHERE i.farm_id = v_farm_id
          AND ROWNUM <= 5
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(r.resource_name || ': ' || r.current_quantity || ' units = ' || r.status);
    END LOOP;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No inventory data found for testing');
END;
/






CREATE OR REPLACE FUNCTION F_GET_AVERAGE_SENSOR_READING (
    p_farm_id      IN NUMBER,
    p_sensor_type  IN VARCHAR2,
    p_days_back    IN NUMBER DEFAULT 7
) RETURN NUMBER
IS
    v_avg_reading NUMBER;
BEGIN
    -- Calculate average reading for specified period
    SELECT AVG(sr.reading_value)
    INTO v_avg_reading
    FROM sensor_reading sr
    JOIN sensor s ON sr.sensor_id = s.sensor_id
    WHERE s.farm_id = p_farm_id
      AND s.sensor_type = p_sensor_type
      AND s.status = 'ACTIVE'
      AND sr.reading_timestamp >= SYSDATE - p_days_back
      AND sr.quality_flag = 'G'; -- Only good quality readings
    
    RETURN ROUND(NVL(v_avg_reading, 0), 2);
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1; -- Error
END F_GET_AVERAGE_SENSOR_READING;
/



-- Test F_GET_AVERAGE_SENSOR_READING
DECLARE
    v_avg_reading NUMBER;
    v_farm_id NUMBER;
    v_sensor_type VARCHAR2(30);
BEGIN
    -- Get farm with sensor readings
    SELECT DISTINCT s.farm_id, s.sensor_type
    INTO v_farm_id, v_sensor_type
    FROM sensor s
    JOIN sensor_reading sr ON s.sensor_id = sr.sensor_id
    WHERE s.status = 'ACTIVE'
      AND sr.quality_flag = 'G'
      AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Testing Function 3: F_GET_AVERAGE_SENSOR_READING');
    DBMS_OUTPUT.PUT_LINE('Farm ID: ' || v_farm_id || ', Sensor Type: ' || v_sensor_type);
    
    -- Test with default 7 days
    v_avg_reading := F_GET_AVERAGE_SENSOR_READING(
        p_farm_id => v_farm_id,
        p_sensor_type => v_sensor_type,
        p_days_back => 7
    );
    
    DBMS_OUTPUT.PUT_LINE('Result (7 days): Average = ' || v_avg_reading);
    
    -- Test with 30 days
    v_avg_reading := F_GET_AVERAGE_SENSOR_READING(
        p_farm_id => v_farm_id,
        p_sensor_type => v_sensor_type,
        p_days_back => 30
    );
    
    DBMS_OUTPUT.PUT_LINE('Result (30 days): Average = ' || v_avg_reading);
    
    -- Test all sensor types for this farm
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('All sensor averages for farm ' || v_farm_id || ' (7 days):');
    FOR r IN (
        SELECT DISTINCT s.sensor_type,
               F_GET_AVERAGE_SENSOR_READING(v_farm_id, s.sensor_type, 7) as avg_reading
        FROM sensor s
        WHERE s.farm_id = v_farm_id
          AND s.status = 'ACTIVE'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(r.sensor_type || ': ' || r.avg_reading);
    END LOOP;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No sensor reading data found for testing');
END;
/

