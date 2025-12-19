
-- Insert 15 crop types with realistic parameters
-- ============================================
INSERT ALL
    INTO crop_type (crop_type_id, crop_name, optimal_moisture, optimal_nutrient_level, growth_stage, created_date) 
    VALUES (1000, 'Maize', 65.00, 150.00, 'VEGETATIVE', DATE '2024-12-01')
    
    INTO crop_type VALUES (1001, 'Wheat', 60.00, 120.00, 'FLOWERING', DATE '2024-12-01')
    INTO crop_type VALUES (1002, 'Rice', 85.00, 160.00, 'RIPENING', DATE '2024-12-01')
    INTO crop_type VALUES (1003, 'Potatoes', 70.00, 200.00, 'TUBER_FORMATION', DATE '2024-12-01')
    INTO crop_type VALUES (1004, 'Tomatoes', 75.00, 170.00, 'FRUITING', DATE '2024-12-01')
    INTO crop_type VALUES (1005, 'Beans', 68.00, 130.00, 'POD_FORMATION', DATE '2024-12-01')
    INTO crop_type VALUES (1006, 'Coffee', 55.00, 140.00, 'BERRY_DEVELOPMENT', DATE '2024-12-01')
    INTO crop_type VALUES (1007, 'Tea', 80.00, 110.00, 'HARVEST_READY', DATE '2024-12-01')
    INTO crop_type VALUES (1008, 'Bananas', 78.00, 220.00, 'BUNCH_DEVELOPMENT', DATE '2024-12-01')
    INTO crop_type VALUES (1009, 'Cassava', 50.00, 90.00, 'ROOT_DEVELOPMENT', DATE '2024-12-01')
    INTO crop_type VALUES (1010, 'Soybeans', 62.00, 160.00, 'POD_FILLING', DATE '2024-12-01')
    INTO crop_type VALUES (1011, 'Carrots', 73.00, 145.00, 'ROOT_BULKING', DATE '2024-12-01')
    INTO crop_type VALUES (1012, 'Onions', 67.00, 125.00, 'BULB_FORMATION', DATE '2024-12-01')
    INTO crop_type VALUES (1013, 'Cabbage', 77.00, 155.00, 'HEAD_FORMATION', DATE '2024-12-01')
    INTO crop_type VALUES (1014, 'Avocado', 58.00, 195.00, 'FRUIT_SET', DATE '2024-12-01')
SELECT 1 FROM DUAL;

COMMIT;

-- ============================================
-- Insert 150 farms using PL/SQL loop
-- ============================================
DECLARE
    v_farm_id NUMBER;
    v_crop_type_id NUMBER;
    v_status VARCHAR2(20);
    v_area NUMBER;
    v_date DATE;
    v_location VARCHAR2(200);
    v_farm_name VARCHAR2(100);
    v_success_count NUMBER := 0;
    v_error_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Starting farm insertion...');
    DBMS_OUTPUT.PUT_LINE('Generating 150 farms across Rwanda...');
    
    FOR i IN 1..150 LOOP
        BEGIN
            v_farm_id := 1000 + (i - 1); -- Start from 1000
            
            -- Assign crop_type_id (1000 to 1014 from crop_type table)
            v_crop_type_id := 1000 + MOD(i, 15);
            
            -- Assign status (mostly ACTIVE, some INACTIVE/SUSPENDED)
            IF i < 120 THEN
                v_status := 'ACTIVE';
            ELSIF i < 140 THEN
                v_status := 'INACTIVE';
            ELSE
                v_status := 'SUSPENDED';
            END IF;
            
            -- Random area between 5 and 500 hectares
            v_area := ROUND(DBMS_RANDOM.VALUE(5, 500), 2);
            
            -- Random registration date between 2020 and 2025
            v_date := DATE '2020-01-01' + DBMS_RANDOM.VALUE(0, 2190);
            
            -- Random location from Rwanda provinces/districts
            CASE MOD(i, 15)
                WHEN 0 THEN v_location := 'Nyagatare, Eastern Province';
                WHEN 1 THEN v_location := 'Musanze, Northern Province';
                WHEN 2 THEN v_location := 'Rubavu, Western Province';
                WHEN 3 THEN v_location := 'Huye, Southern Province';
                WHEN 4 THEN v_location := 'Kicukiro, Kigali';
                WHEN 5 THEN v_location := 'Muhanga, Southern Province';
                WHEN 6 THEN v_location := 'Karongi, Western Province';
                WHEN 7 THEN v_location := 'Bugesera, Eastern Province';
                WHEN 8 THEN v_location := 'Ngoma, Eastern Province';
                WHEN 9 THEN v_location := 'Rulindo, Northern Province';
                WHEN 10 THEN v_location := 'Gatsibo, Eastern Province';
                WHEN 11 THEN v_location := 'Nyarugenge, Kigali';
                WHEN 12 THEN v_location := 'Kayonza, Eastern Province';
                WHEN 13 THEN v_location := 'Nyamagabe, Southern Province';
                ELSE v_location := 'Gasabo, Kigali';
            END CASE;
            
            -- Farm name generation
            v_farm_name := 'Farm_' || LPAD(i, 3, '0') || '_' || 
                          SUBSTR(v_location, 1, INSTR(v_location, ',')-1);
            
            INSERT INTO farm (farm_id, farm_name, location, crop_type_id, contact_info, registration_date, status, total_area_hectares)
            VALUES (v_farm_id, v_farm_name, v_location, v_crop_type_id, 
                   '+25078' || LPAD(MOD(i * 137, 900000) + 100000, 6, '0'), 
                   v_date, v_status, v_area);
            
            v_success_count := v_success_count + 1;
            
            -- Progress indicator
            IF MOD(i, 30) = 0 THEN
                DBMS_OUTPUT.PUT_LINE('   Processed ' || i || ' farms...');
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                v_error_count := v_error_count + 1;
                DBMS_OUTPUT.PUT_LINE('Error inserting farm ' || i || ': ' || SQLERRM);
        END;
    END LOOP;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '============================================');
    DBMS_OUTPUT.PUT_LINE('INSERTION SUMMARY:');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Successfully inserted: ' || v_success_count || ' farms');
    DBMS_OUTPUT.PUT_LINE('Errors: ' || v_error_count);
    DBMS_OUTPUT.PUT_LINE('Farm IDs range: 1000 - ' || (1000 + v_success_count - 1));
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Fatal error: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/
-- SENSOR Table – Insert 300+ sensors (2–5 per farm)


DECLARE
    v_sensor_id NUMBER := 1000;
    v_sensor_types VARCHAR2(200) := 'MOISTURE,TEMPERATURE,PH,NUTRIENT,HUMIDITY,LIGHT';
    v_status_list VARCHAR2(200) := 'ACTIVE,INACTIVE,MAINTENANCE,FAULTY';
    v_sensor_type VARCHAR2(30);
    v_status VARCHAR2(20);
    v_lat NUMBER;
    v_long NUMBER;
    v_farm_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_farm_count FROM farm;
    DBMS_OUTPUT.PUT_LINE('Total farms: ' || v_farm_count);
    
    FOR f IN (SELECT farm_id FROM farm ORDER BY farm_id) LOOP
        -- Insert 2 to 5 sensors per farm
        FOR i IN 1..(MOD(f.farm_id, 4) + 2) LOOP
            -- Random sensor type
            v_sensor_type := 
                CASE MOD(v_sensor_id, 6)
                    WHEN 0 THEN 'MOISTURE'
                    WHEN 1 THEN 'TEMPERATURE'
                    WHEN 2 THEN 'PH'
                    WHEN 3 THEN 'NUTRIENT'
                    WHEN 4 THEN 'HUMIDITY'
                    ELSE 'LIGHT'
                END;
            
            -- Mostly ACTIVE, some other statuses
            IF MOD(v_sensor_id, 10) = 0 THEN
                v_status := 'MAINTENANCE';
            ELSIF MOD(v_sensor_id, 20) = 0 THEN
                v_status := 'FAULTY';
            ELSIF MOD(v_sensor_id, 15) = 0 THEN
                v_status := 'INACTIVE';
            ELSE
                v_status := 'ACTIVE';
            END IF;
            
            -- Random coordinates in Rwanda
            v_lat := -1.9 + DBMS_RANDOM.VALUE(-0.3, 0.3); -- approx Rwanda lat range
            v_long := 29.7 + DBMS_RANDOM.VALUE(-0.5, 0.5); -- approx Rwanda long range
            
            INSERT INTO sensor (sensor_id, farm_id, sensor_type, sensor_model, status, installation_date, last_calibration_date, latitude, longitude)
            VALUES (v_sensor_id, f.farm_id, v_sensor_type, 'Model_' || CHR(65 + MOD(v_sensor_id, 5)), v_status,
                    DATE '2023-01-01' + DBMS_RANDOM.VALUE(0, 730), -- random date in last 2 years
                    DATE '2023-06-01' + DBMS_RANDOM.VALUE(0, 365), -- calibration within last year
                    v_lat, v_long);
            
            v_sensor_id := v_sensor_id + 1;
        END LOOP;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted ' || (v_sensor_id - 1000) || ' sensors.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/



-- SENSOR_READING Table – Insert 10,000+ readings (time-series)

DECLARE
    v_reading_id NUMBER := 1;
    v_start_time TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    v_interval NUMBER;
    v_quality CHAR(1);
    v_sensor_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_sensor_count FROM sensor WHERE status = 'ACTIVE';
    DBMS_OUTPUT.PUT_LINE('Active sensors: ' || v_sensor_count);
    
    FOR s IN (SELECT sensor_id, sensor_type FROM sensor WHERE status = 'ACTIVE') LOOP
        -- Generate 50–200 readings per sensor
        FOR i IN 1..(MOD(s.sensor_id, 150) + 50) LOOP
            v_interval := DBMS_RANDOM.VALUE(0, 86400 * 180); -- up to 180 days in seconds
            
            -- Random quality flag (mostly Good, some Suspect/Bad)
            v_quality := CASE 
                WHEN MOD(i, 20) = 0 THEN 'S' -- Suspect
                WHEN MOD(i, 50) = 0 THEN 'B' -- Bad
                ELSE 'G' 
            END;
            
            INSERT INTO sensor_reading (reading_id, sensor_id, reading_value, reading_type, reading_timestamp, unit, quality_flag)
            VALUES (v_reading_id, s.sensor_id,
                    ROUND(DBMS_RANDOM.VALUE(10, 100), 2), -- random reading value
                    s.sensor_type,
                    v_start_time + NUMTODSINTERVAL(v_interval, 'SECOND'),
                    CASE s.sensor_type
                        WHEN 'MOISTURE' THEN '%'
                        WHEN 'TEMPERATURE' THEN '°C'
                        WHEN 'PH' THEN 'pH'
                        WHEN 'NUTRIENT' THEN 'ppm'
                        WHEN 'HUMIDITY' THEN '%'
                        ELSE 'lux'
                    END,
                    v_quality);
            
            v_reading_id := v_reading_id + 1;
        END LOOP;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted ' || (v_reading_id - 1) || ' sensor readings.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/





-- 1A. Fix the unit_cost column if needed
ALTER TABLE resource_type MODIFY (unit_cost NUMBER(12,2));

-- 1B. Insert 20 resource types
INSERT ALL
    INTO resource_type (resource_id, resource_name, unit, optimal_level, reorder_level, unit_cost, supplier, category) 
    VALUES (1100, 'Urea Fertilizer', 'kg', 100, 20, 800, 'AgroSupply Rwanda', 'FERTILIZER')
    INTO resource_type VALUES (1101, 'NPK 17-17-17', 'kg', 150, 30, 1200, 'Green Agro Ltd', 'FERTILIZER')
    INTO resource_type VALUES (1102, 'Calcium Nitrate', 'kg', 80, 15, 1500, 'FertiTech', 'FERTILIZER')
    INTO resource_type VALUES (1103, 'Irrigation Water', 'm³', 500, 100, 50, 'RWB Water Authority', 'WATER')
    INTO resource_type VALUES (1104, 'Pesticide A', 'L', 50, 10, 2500, 'CropShield Inc', 'PESTICIDE')
    INTO resource_type VALUES (1105, 'Herbicide B', 'L', 40, 8, 1800, 'WeedFree Corp', 'PESTICIDE')
    INTO resource_type VALUES (1106, 'Tractor', 'unit', 5, 1, 15000000, 'John Deere Rwanda', 'EQUIPMENT')
    INTO resource_type VALUES (1107, 'Sprinkler System', 'unit', 10, 2, 500000, 'IrriTech Ltd', 'EQUIPMENT')
    INTO resource_type VALUES (1108, 'Harvester', 'unit', 3, 1, 30000000, 'Case IH', 'EQUIPMENT')
    INTO resource_type VALUES (1109, 'Seeds Maize', 'kg', 200, 50, 1500, 'SeedCo Rwanda', 'OTHER')
    INTO resource_type VALUES (1110, 'Seeds Coffee', 'kg', 100, 20, 8000, 'Arabica Seeds Ltd', 'OTHER')
    INTO resource_type VALUES (1111, 'Organic Compost', 'kg', 300, 60, 300, 'EcoFarm Rwanda', 'FERTILIZER')
    INTO resource_type VALUES (1112, 'Growth Hormone', 'L', 30, 5, 5000, 'BioGrow Inc', 'OTHER')
    INTO resource_type VALUES (1113, 'Soil Testing Kit', 'kit', 15, 3, 25000, 'LabTech Supplies', 'EQUIPMENT')
    INTO resource_type VALUES (1114, 'Protective Gear', 'set', 50, 10, 15000, 'SafetyFirst Ltd', 'OTHER')
    INTO resource_type VALUES (1115, 'Diesel Fuel', 'L', 200, 50, 1200, 'Total Rwanda', 'OTHER')
    INTO resource_type VALUES (1116, 'Irrigation Pipes', 'm', 100, 20, 3000, 'PipeTech Ltd', 'EQUIPMENT')
    INTO resource_type VALUES (1117, 'Greenhouse Cover', 'sheet', 50, 10, 8000, 'AgroCover Ltd', 'EQUIPMENT')
    INTO resource_type VALUES (1118, 'Fungicide C', 'L', 30, 5, 3200, 'FungFree Inc', 'PESTICIDE')
    INTO resource_type VALUES (1119, 'Lime Powder', 'kg', 200, 40, 600, 'SoilBalance Ltd', 'FERTILIZER')
SELECT 1 FROM DUAL;

COMMIT;

-- Verify
SELECT COUNT(*) FROM resource_type;




-- Insert 50+ users with different roles
DECLARE
    v_user_id NUMBER;
    v_roles SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('FARMER', 'MANAGER', 'ADMIN', 'AGROLOGIST', 'VIEWER');
    v_role VARCHAR2(30);
    v_status VARCHAR2(20);
    v_farm_id NUMBER;
BEGIN
    -- Start from sequence last_number
    SELECT NVL(MAX(user_id), 99) + 1 INTO v_user_id FROM agri_user;
    
    FOR i IN 1..50 LOOP
        -- Assign role (more farmers, fewer admins)
        IF i <= 30 THEN
            v_role := 'FARMER';
        ELSIF i <= 40 THEN
            v_role := 'MANAGER';
        ELSIF i <= 45 THEN
            v_role := 'AGROLOGIST';
        ELSIF i <= 48 THEN
            v_role := 'ADMIN';
        ELSE
            v_role := 'VIEWER';
        END IF;
        
        -- Assign status (mostly active)
        IF MOD(i, 10) = 0 THEN
            v_status := 'INACTIVE';
        ELSIF MOD(i, 15) = 0 THEN
            v_status := 'SUSPENDED';
        ELSE
            v_status := 'ACTIVE';
        END IF;
        
        -- Assign farm_id to some users (farmers mostly)
        IF v_role = 'FARMER' AND MOD(i, 2) = 0 THEN
            SELECT farm_id INTO v_farm_id 
            FROM (SELECT farm_id FROM farm WHERE status = 'ACTIVE' ORDER BY DBMS_RANDOM.VALUE) 
            WHERE ROWNUM = 1;
        ELSE
            v_farm_id := NULL;
        END IF;
        
        INSERT INTO agri_user (user_id, username, password_hash, role, email, full_name, phone_number, created_at, last_login, status, farm_id)
        VALUES (v_user_id,
                'user' || LPAD(v_user_id, 3, '0'),
                DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT => UTL_RAW.CAST_TO_RAW('password' || v_user_id)),
                v_role,
                'user' || v_user_id || '@agrioptima.rw',
                'User ' || v_user_id || ' ' || INITCAP(v_role),
                '+25078' || LPAD(MOD(v_user_id * 7, 900000) + 100000, 6, '0'),
                DATE '2023-01-01' + DBMS_RANDOM.VALUE(0, 730),
                SYSDATE - DBMS_RANDOM.VALUE(0, 90),
                v_status,
                v_farm_id);
        
        v_user_id := v_user_id + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted 50 users.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Verify
SELECT role, COUNT(*) as count, status FROM agri_user GROUP BY role, status ORDER BY role;







-- Insert 200+ inventory records
DECLARE
    v_inventory_id NUMBER := 1;
    v_farm_count NUMBER;
    v_resource_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_farm_count FROM farm WHERE status = 'ACTIVE';
    SELECT COUNT(*) INTO v_resource_count FROM resource_type;
    
    DBMS_OUTPUT.PUT_LINE('Active farms: ' || v_farm_count || ', Resources: ' || v_resource_count);
    
    FOR f IN (SELECT farm_id FROM farm WHERE status = 'ACTIVE') LOOP
        FOR r IN (SELECT resource_id FROM resource_type) LOOP
            -- Create inventory for ~40% of farm-resource combos
            IF DBMS_RANDOM.VALUE(0,1) <= 0.4 THEN
                INSERT INTO inventory (inventory_id, farm_id, resource_id, current_quantity, last_replenish_date, next_reorder_date, storage_location, batch_number)
                VALUES (v_inventory_id, 
                        f.farm_id, 
                        r.resource_id,
                        ROUND(DBMS_RANDOM.VALUE(10, 500), 2),
                        SYSDATE - DBMS_RANDOM.VALUE(10, 180),
                        SYSDATE + DBMS_RANDOM.VALUE(10, 90),
                        'WH' || MOD(f.farm_id, 5) || '-S' || MOD(v_inventory_id, 10),
                        'BATCH-' || TO_CHAR(SYSDATE - 30, 'YYYYMMDD') || '-' || LPAD(v_inventory_id, 4, '0'));
                
                v_inventory_id := v_inventory_id + 1;
            END IF;
        END LOOP;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted ' || (v_inventory_id - 1) || ' inventory records.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Verify
SELECT COUNT(*) FROM inventory;







-- Insert 300+ allocation records
DECLARE
    v_allocation_id NUMBER := 1;
    v_user_count NUMBER;
    v_status_list SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('COMPLETED', 'PENDING', 'FAILED', 'CANCELLED');
    v_type_list SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('AUTOMATED', 'MANUAL', 'EMERGENCY');
BEGIN
    SELECT COUNT(*) INTO v_user_count FROM agri_user WHERE status = 'ACTIVE';
    
    FOR i IN 1..300 LOOP
        INSERT INTO allocation_log (allocation_id, farm_id, resource_id, allocated_quantity, allocation_timestamp, user_id, status, allocation_type, reason)
        SELECT 
            v_allocation_id,
            f.farm_id,
            r.resource_id,
            ROUND(DBMS_RANDOM.VALUE(5, 100), 2),
            SYSDATE - DBMS_RANDOM.VALUE(0, 90),
            u.user_id,
            v_status_list(MOD(i, 4) + 1),
            v_type_list(MOD(i, 3) + 1),
            CASE 
                WHEN MOD(i, 10) = 0 THEN 'Emergency requirement'
                WHEN MOD(i, 5) = 0 THEN 'Scheduled maintenance'
                ELSE 'Regular allocation'
            END
        FROM 
            (SELECT farm_id FROM farm WHERE status = 'ACTIVE' ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY) f,
            (SELECT resource_id FROM resource_type ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY) r,
            (SELECT user_id FROM agri_user WHERE status = 'ACTIVE' ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY) u;
        
        v_allocation_id := v_allocation_id + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted ' || (v_allocation_id - 1) || ' allocation records.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Verify
SELECT allocation_type, status, COUNT(*) as count FROM allocation_log GROUP BY allocation_type, status;






-- Insert 100+ alert records
DECLARE
    v_alert_id NUMBER := 1;
    v_alert_types SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(
        'LOW_STOCK', 'HIGH_MOISTURE', 'LOW_MOISTURE', 
        'HIGH_TEMP', 'LOW_TEMP', 'PEST_DETECTION', 
        'EQUIPMENT_FAILURE', 'SCHEDULE_MISSED'
    );
    v_severities SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
    v_statuses SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED', 'DISMISSED');
    v_alert_message VARCHAR2(200);
BEGIN
    FOR i IN 1..100 LOOP
        -- Generate appropriate alert message based on type
        CASE v_alert_types(MOD(i, 8) + 1)
            WHEN 'LOW_STOCK' THEN v_alert_message := 'Resource stock below reorder level. Immediate attention required.';
            WHEN 'HIGH_MOISTURE' THEN v_alert_message := 'Soil moisture level exceeds optimal range. Risk of root rot.';
            WHEN 'LOW_MOISTURE' THEN v_alert_message := 'Soil moisture level below optimal range. Irrigation needed.';
            WHEN 'HIGH_TEMP' THEN v_alert_message := 'Temperature above threshold. Crop stress detected.';
            WHEN 'LOW_TEMP' THEN v_alert_message := 'Temperature below threshold. Frost risk imminent.';
            WHEN 'PEST_DETECTION' THEN v_alert_message := 'Pest activity detected in monitoring area.';
            WHEN 'EQUIPMENT_FAILURE' THEN v_alert_message := 'Sensor/Equipment malfunction reported.';
            WHEN 'SCHEDULE_MISSED' THEN v_alert_message := 'Scheduled maintenance/activity not completed.';
        END CASE;
        
        INSERT INTO alert_log (alert_id, farm_id, alert_type, alert_message, alert_timestamp, status, severity, acknowledged_by, acknowledged_date)
        SELECT 
            v_alert_id,
            f.farm_id,
            v_alert_types(MOD(i, 8) + 1),
            v_alert_message,
            SYSDATE - DBMS_RANDOM.VALUE(0, 30), -- Last 30 days
            v_statuses(MOD(i, 4) + 1),
            v_severities(MOD(i, 4) + 1),
            CASE WHEN MOD(i, 3) = 0 THEN 
                (SELECT user_id FROM agri_user WHERE role IN ('MANAGER', 'ADMIN') AND status = 'ACTIVE' ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY)
            END,
            CASE WHEN MOD(i, 3) = 0 THEN SYSDATE - DBMS_RANDOM.VALUE(0, 5) END
        FROM 
            (SELECT farm_id FROM farm WHERE status = 'ACTIVE' ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY) f;
        
        v_alert_id := v_alert_id + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted ' || (v_alert_id - 1) || ' alert records.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Verify
SELECT alert_type, severity, status, COUNT(*) as count 
FROM alert_log 
GROUP BY alert_type, severity, status 
ORDER BY alert_type, severity;








-- Insert Rwanda public holidays for 2024-2025
INSERT ALL
    INTO holiday (holiday_date, holiday_name, country, holiday_type) VALUES (DATE '2024-01-01', 'New Year''s Day', 'RWANDA', 'PUBLIC')
    INTO holiday VALUES (DATE '2024-02-01', 'National Heroes Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2024-04-07', 'Genocide against the Tutsi Memorial Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2024-05-01', 'Labour Day', 'RWANDA', 'PUBLIC')
    INTO holiday VALUES (DATE '2024-07-01', 'Independence Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2024-07-04', 'Liberation Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2024-08-15', 'Assumption Day', 'RWANDA', 'RELIGIOUS')
    INTO holiday VALUES (DATE '2024-09-25', 'Umuganura Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2024-12-25', 'Christmas Day', 'RWANDA', 'PUBLIC')
    INTO holiday VALUES (DATE '2024-12-26', 'Boxing Day', 'RWANDA', 'PUBLIC')
    
    -- 2025 holidays
    INTO holiday VALUES (DATE '2025-01-01', 'New Year''s Day', 'RWANDA', 'PUBLIC')
    INTO holiday VALUES (DATE '2025-02-01', 'National Heroes Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2025-04-07', 'Genocide against the Tutsi Memorial Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2025-05-01', 'Labour Day', 'RWANDA', 'PUBLIC')
    INTO holiday VALUES (DATE '2025-07-01', 'Independence Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2025-07-04', 'Liberation Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2025-08-15', 'Assumption Day', 'RWANDA', 'RELIGIOUS')
    INTO holiday VALUES (DATE '2025-09-25', 'Umuganura Day', 'RWANDA', 'NATIONAL')
    INTO holiday VALUES (DATE '2025-12-25', 'Christmas Day', 'RWANDA', 'PUBLIC')
    INTO holiday VALUES (DATE '2025-12-26', 'Boxing Day', 'RWANDA', 'PUBLIC')
SELECT 1 FROM DUAL;

COMMIT;

-- Verify
SELECT holiday_date, holiday_name, holiday_type 
FROM holiday 
ORDER BY holiday_date;

