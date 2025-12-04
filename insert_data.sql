-- =========================================================
-- AgriOptima Bulk Data Insertion
-- Author: Rukundo
-- Purpose: Populate all 7 tables with sample records
-- =========================================================

-- 1. Insert into CROP_PROFILES
BEGIN
  INSERT INTO CROP_PROFILES VALUES (1, 'Maize', 25, 120, 5);
  INSERT INTO CROP_PROFILES VALUES (2, 'Beans', 30, 100, 3);
  INSERT INTO CROP_PROFILES VALUES (3, 'Wheat', 20, 110, 4);
  INSERT INTO CROP_PROFILES VALUES (4, 'Potatoes', 28, 95, 6);
END;
/

-- 2. Insert into FARM_SECTIONS (20 sections, randomized area & status)
BEGIN
  FOR i IN 1..20 LOOP
    INSERT INTO FARM_SECTIONS (
      section_id, crop_type_id, section_area_sqm, current_status
    ) VALUES (
      100 + i,
      MOD(i,4)+1,  -- rotates crop_type_id 1–4
      ROUND(DBMS_RANDOM.VALUE(200,800),0),
      CASE WHEN MOD(i,2)=0 THEN 'Healthy' ELSE 'Needs Attention' END
    );
  END LOOP;
END;
/

-- 3. Insert into SENSOR_READINGS (500 readings across sections)
BEGIN
  FOR i IN 1..500 LOOP
    INSERT INTO SENSOR_READINGS (
      reading_id, section_id, reading_timestamp, soil_moisture_pct, nutrient_level_ppm
    ) VALUES (
      1000 + i,
      100 + MOD(i,20)+1,  -- matches FARM_SECTIONS IDs
      SYSDATE - MOD(i,30),
      ROUND(DBMS_RANDOM.VALUE(15,40),2),
      ROUND(DBMS_RANDOM.VALUE(80,140),2)
    );
  END LOOP;
END;
/

-- 4. Insert into RESOURCE_INVENTORY
BEGIN
  INSERT INTO RESOURCE_INVENTORY VALUES (201, 'Water', 10000, 2000);
  INSERT INTO RESOURCE_INVENTORY VALUES (202, 'Fertilizer', 5000, 1000);
  INSERT INTO RESOURCE_INVENTORY VALUES (203, 'Pesticide', 2000, 500);
  INSERT INTO RESOURCE_INVENTORY VALUES (204, 'Seeds', 3000, 600);
  INSERT INTO RESOURCE_INVENTORY VALUES (205, 'Labor Hours', 1000, 200);
END;
/

-- 5. Insert into ALLOCATION_LOG (200 allocations)
BEGIN
  FOR i IN 1..200 LOOP
    INSERT INTO ALLOCATION_LOG (
      log_id, section_id, resource_id, quantity_applied, allocation_timestamp
    ) VALUES (
      2000 + i,
      100 + MOD(i,20)+1,
      200 + MOD(i,5)+1,
      ROUND(DBMS_RANDOM.VALUE(10,100),0),
      SYSDATE - MOD(i,15)
    );
  END LOOP;
END;
/

-- 6. Insert into ALERT_LOG (50 alerts alternating types)
BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO ALERT_LOG (
      alert_id, alert_timestamp, alert_type, message_text
    ) VALUES (
      3000 + i,
      SYSDATE - MOD(i,10),
      CASE WHEN MOD(i,2)=0 THEN 'Low Stock' ELSE 'Sensor Warning' END,
      CASE WHEN MOD(i,2)=0 THEN 'Resource below threshold' ELSE 'Abnormal moisture detected' END
    );
  END LOOP;
END;
/

-- 7. Insert into HOLIDAYS
BEGIN
  INSERT INTO HOLIDAYS VALUES (TO_DATE('25-DEC-2025','DD-MON-YYYY'), 'Christmas Day');
  INSERT INTO HOLIDAYS VALUES (TO_DATE('01-JAN-2026','DD-MON-YYYY'), 'New Year');
  INSERT INTO HOLIDAYS VALUES (TO_DATE('07-APR-2026','DD-MON-YYYY'), 'Genocide Memorial Day');
END;
/
