-- Cursor 1: Process all sensors for a farm

DECLARE
    CURSOR c_low_stock_alerts IS
        SELECT a.alert_id, a.farm_id, a.alert_message, 
               f.farm_name, r.resource_name
        FROM alert_log a
        JOIN farm f ON a.farm_id = f.farm_id
        LEFT JOIN resource_type r ON a.alert_message LIKE '%' || r.resource_name || '%'
        WHERE a.alert_type = 'LOW_STOCK'
          AND a.status = 'ACTIVE'
          AND a.alert_timestamp < SYSDATE - 2 -- Older than 2 days
        FOR UPDATE OF a.status NOWAIT; -- Lock rows for update
    
    v_updated_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Cursor 2: Processing stale low stock alerts');
    DBMS_OUTPUT.PUT_LINE('============================================');
    
    FOR alert_rec IN c_low_stock_alerts LOOP
        BEGIN
            -- Update alert status to resolved
            UPDATE alert_log
            SET status = 'RESOLVED',
                acknowledged_date = SYSDATE
            WHERE alert_id = alert_rec.alert_id;
            
            v_updated_count := v_updated_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Updated Alert ID: ' || alert_rec.alert_id);
            DBMS_OUTPUT.PUT_LINE('  Farm: ' || alert_rec.farm_name || ' (' || alert_rec.farm_id || ')');
            DBMS_OUTPUT.PUT_LINE('  Resource: ' || NVL(alert_rec.resource_name, 'Unknown'));
            DBMS_OUTPUT.PUT_LINE('  Message: ' || SUBSTR(alert_rec.alert_message, 1, 50) || '...');
            DBMS_OUTPUT.PUT_LINE('---');
            
            -- Commit every 5 records to avoid large transaction
            IF MOD(v_updated_count, 5) = 0 THEN
                COMMIT;
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error updating alert ' || alert_rec.alert_id || ': ' || SQLERRM);
        END;
    END LOOP;
    
    COMMIT; -- Final commit
    
    DBMS_OUTPUT.PUT_LINE('Total alerts updated: ' || v_updated_count);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Cursor error: ' || SQLERRM);
END;
/



-- Cursor 2: Process low stock alerts and update status
DECLARE
    CURSOR c_low_stock_alerts IS
        SELECT a.alert_id, a.farm_id, a.alert_message, 
               f.farm_name, r.resource_name
        FROM alert_log a
        JOIN farm f ON a.farm_id = f.farm_id
        LEFT JOIN resource_type r ON a.alert_message LIKE '%' || r.resource_name || '%'
        WHERE a.alert_type = 'LOW_STOCK'
          AND a.status = 'ACTIVE'
          AND a.alert_timestamp < SYSDATE - 2 -- Older than 2 days
        FOR UPDATE OF a.status NOWAIT; -- Lock rows for update
    
    v_updated_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Cursor 2: Processing stale low stock alerts');
    DBMS_OUTPUT.PUT_LINE('============================================');
    
    FOR alert_rec IN c_low_stock_alerts LOOP
        BEGIN
            -- Update alert status to resolved
            UPDATE alert_log
            SET status = 'RESOLVED',
                acknowledged_date = SYSDATE
            WHERE alert_id = alert_rec.alert_id;
            
            v_updated_count := v_updated_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Updated Alert ID: ' || alert_rec.alert_id);
            DBMS_OUTPUT.PUT_LINE('  Farm: ' || alert_rec.farm_name || ' (' || alert_rec.farm_id || ')');
            DBMS_OUTPUT.PUT_LINE('  Resource: ' || NVL(alert_rec.resource_name, 'Unknown'));
            DBMS_OUTPUT.PUT_LINE('  Message: ' || SUBSTR(alert_rec.alert_message, 1, 50) || '...');
            DBMS_OUTPUT.PUT_LINE('---');
            
            -- Commit every 5 records to avoid large transaction
            IF MOD(v_updated_count, 5) = 0 THEN
                COMMIT;
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error updating alert ' || alert_rec.alert_id || ': ' || SQLERRM);
        END;
    END LOOP;
    
    COMMIT; -- Final commit
    
    DBMS_OUTPUT.PUT_LINE('Total alerts updated: ' || v_updated_count);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Cursor error: ' || SQLERRM);
END;
/


-- Cursor 2 : Process low stock alerts without FOR UPDATE
DECLARE
    CURSOR c_low_stock_alerts IS
        SELECT a.alert_id, a.farm_id, a.alert_message, 
               f.farm_name, r.resource_name
        FROM alert_log a
        JOIN farm f ON a.farm_id = f.farm_id
        LEFT JOIN resource_type r ON a.alert_message LIKE '%' || r.resource_name || '%'
        WHERE a.alert_type = 'LOW_STOCK'
          AND a.status = 'ACTIVE'
          AND a.alert_timestamp < SYSDATE - 2; -- Older than 2 days
    
    v_updated_count NUMBER := 0;
    v_alert_ids SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
BEGIN
    DBMS_OUTPUT.PUT_LINE('Cursor 2 (Fixed): Processing stale low stock alerts');
    DBMS_OUTPUT.PUT_LINE('===================================================');
    
    -- First, collect alert IDs
    FOR alert_rec IN c_low_stock_alerts LOOP
        v_alert_ids.EXTEND;
        v_alert_ids(v_alert_ids.COUNT) := alert_rec.alert_id;
        
        DBMS_OUTPUT.PUT_LINE('Found Alert ID: ' || alert_rec.alert_id);
        DBMS_OUTPUT.PUT_LINE('  Farm: ' || alert_rec.farm_name || ' (' || alert_rec.farm_id || ')');
        DBMS_OUTPUT.PUT_LINE('  Resource: ' || NVL(alert_rec.resource_name, 'Unknown'));
        DBMS_OUTPUT.PUT_LINE('---');
    END LOOP;
    
    -- Then update them
    IF v_alert_ids.COUNT > 0 THEN
        FORALL i IN 1..v_alert_ids.COUNT
            UPDATE alert_log
            SET status = 'RESOLVED',
                acknowledged_date = SYSDATE
            WHERE alert_id = v_alert_ids(i);
        
        v_updated_count := v_alert_ids.COUNT;
        COMMIT;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Total alerts updated: ' || v_updated_count);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Cursor 3: Bulk processing of sensor readings (Efficient for large data)
DECLARE
    TYPE t_sensor_readings IS TABLE OF sensor_reading%ROWTYPE;
    v_readings t_sensor_readings;
    
    CURSOR c_old_readings (p_days_old NUMBER) IS
        SELECT *
        FROM sensor_reading
        WHERE reading_timestamp < SYSDATE - p_days_old
          AND quality_flag = 'B' -- Bad quality readings
        ORDER BY reading_timestamp;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Cursor 3: Bulk processing of old bad-quality readings');
    DBMS_OUTPUT.PUT_LINE('=====================================================');
    
    OPEN c_old_readings(180); -- Readings older than 180 days
    
    LOOP
        FETCH c_old_readings BULK COLLECT INTO v_readings LIMIT 1000; -- Process 1000 at a time
        
        EXIT WHEN v_readings.COUNT = 0;
        
        DBMS_OUTPUT.PUT_LINE('Processing batch of ' || v_readings.COUNT || ' readings');
        
        -- Process each reading in the batch
        FOR i IN 1..v_readings.COUNT LOOP
            -- Example: Archive or delete old bad readings
            -- DELETE FROM sensor_reading WHERE reading_id = v_readings(i).reading_id;
            
            -- For now, just log them
            IF i <= 3 THEN -- Show first 3 as example
                DBMS_OUTPUT.PUT_LINE('  Reading ID: ' || v_readings(i).reading_id || 
                                   ', Value: ' || v_readings(i).reading_value ||
                                   ', Time: ' || TO_CHAR(v_readings(i).reading_timestamp, 'DD-MON-YY'));
            END IF;
        END LOOP;
        
        -- Commit batch
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Batch processed and committed');
        DBMS_OUTPUT.PUT_LINE('---');
    END LOOP;
    
    CLOSE c_old_readings;
    
    DBMS_OUTPUT.PUT_LINE('Bulk processing complete');
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_old_readings%ISOPEN THEN
            CLOSE c_old_readings;
        END IF;
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Bulk processing error: ' || SQLERRM);
END;
/
