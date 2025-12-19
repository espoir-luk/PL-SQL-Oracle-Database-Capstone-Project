-- ============================================
-- CREATE INDEXES for AgriOptima Enhanced BI
-- Phase V: Table Implementation
-- Student: [Your Name]
-- Student ID: [Your ID]
-- Date: December 19, 2024
-- ============================================

-- ============================================
-- 1. Indexes for CROP_TYPE table
-- ============================================
CREATE INDEX idx_crop_type_name ON crop_type(crop_name) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('Index idx_crop_type_name created on crop_type(crop_name)');

-- ============================================
-- 2. Indexes for FARM table
-- ============================================
CREATE INDEX idx_farm_crop_type ON farm(crop_type_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_farm_location ON farm(location) TABLESPACE agrioptima_idx;
CREATE INDEX idx_farm_status ON farm(status) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('3 indexes created on farm table');

-- ============================================
-- 3. Indexes for SENSOR table
-- ============================================
CREATE INDEX idx_sensor_farm ON sensor(farm_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_sensor_type ON sensor(sensor_type) TABLESPACE agrioptima_idx;
CREATE INDEX idx_sensor_status ON sensor(status) TABLESPACE agrioptima_idx;
CREATE INDEX idx_sensor_location ON sensor(latitude, longitude) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('4 indexes created on sensor table');

-- ============================================
-- 4. Indexes for SENSOR_READING table
-- Critical for time-series queries
-- ============================================
CREATE INDEX idx_reading_sensor ON sensor_reading(sensor_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_reading_timestamp ON sensor_reading(reading_timestamp) TABLESPACE agrioptima_idx;
CREATE INDEX idx_reading_sensor_time ON sensor_reading(sensor_id, reading_timestamp) TABLESPACE agrioptima_idx;
CREATE INDEX idx_reading_type ON sensor_reading(reading_type) TABLESPACE agrioptima_idx;
CREATE INDEX idx_reading_quality ON sensor_reading(quality_flag) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('5 indexes created on sensor_reading table (optimized for time-series)');

-- ============================================
-- 5. Indexes for RESOURCE_TYPE table
-- ============================================
CREATE INDEX idx_resource_category ON resource_type(category) TABLESPACE agrioptima_idx;
CREATE INDEX idx_resource_supplier ON resource_type(supplier) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('2 indexes created on resource_type table');

-- ============================================
-- 6. Indexes for INVENTORY table
-- ============================================
CREATE INDEX idx_inv_farm ON inventory(farm_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_inv_resource ON inventory(resource_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_inv_reorder ON inventory(next_reorder_date) TABLESPACE agrioptima_idx;
CREATE INDEX idx_inv_quantity ON inventory(current_quantity) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('4 indexes created on inventory table');

-- ============================================
-- 7. Indexes for ALLOCATION_LOG table
-- ============================================
CREATE INDEX idx_alloc_farm ON allocation_log(farm_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_alloc_resource ON allocation_log(resource_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_alloc_timestamp ON allocation_log(allocation_timestamp) TABLESPACE agrioptima_idx;
CREATE INDEX idx_alloc_user ON allocation_log(user_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_alloc_status ON allocation_log(status) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('5 indexes created on allocation_log table');

-- ============================================
-- 8. Indexes for ALERT_LOG table
-- ============================================
CREATE INDEX idx_alert_farm ON alert_log(farm_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_alert_timestamp ON alert_log(alert_timestamp) TABLESPACE agrioptima_idx;
CREATE INDEX idx_alert_status ON alert_log(status) TABLESPACE agrioptima_idx;
CREATE INDEX idx_alert_type ON alert_log(alert_type) TABLESPACE agrioptima_idx;
CREATE INDEX idx_alert_severity ON alert_log(severity) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('5 indexes created on alert_log table');

-- ============================================
-- 9. Indexes for AGRI_USER table
-- ============================================
CREATE INDEX idx_user_role ON agri_user(role) TABLESPACE agrioptima_idx;
CREATE INDEX idx_user_farm ON agri_user(farm_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_user_status ON agri_user(status) TABLESPACE agrioptima_idx;
CREATE INDEX idx_user_email ON agri_user(email) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('4 indexes created on agri_user table');

-- ============================================
-- 10. Indexes for HOLIDAY table
-- ============================================
CREATE INDEX idx_holiday_date ON holiday(holiday_date) TABLESPACE agrioptima_idx;
CREATE INDEX idx_holiday_type ON holiday(holiday_type) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('2 indexes created on holiday table');

-- ============================================
-- 11. Indexes for AUDIT_LOG table
-- Critical for Phase VII auditing
-- ============================================
CREATE INDEX idx_audit_table ON audit_log(table_name) TABLESPACE agrioptima_idx;
CREATE INDEX idx_audit_timestamp ON audit_log(action_timestamp) TABLESPACE agrioptima_idx;
CREATE INDEX idx_audit_user ON audit_log(user_id) TABLESPACE agrioptima_idx;
CREATE INDEX idx_audit_action ON audit_log(action_type) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('4 indexes created on audit_log table (optimized for audit queries)');

-- ============================================
-- Function-based indexes for performance
-- ============================================
CREATE INDEX idx_farm_name_upper ON farm(UPPER(farm_name)) TABLESPACE agrioptima_idx;
CREATE INDEX idx_user_username_upper ON agri_user(UPPER(username)) TABLESPACE agrioptima_idx;
CREATE INDEX idx_crop_name_upper ON crop_type(UPPER(crop_name)) TABLESPACE agrioptima_idx;
DBMS_OUTPUT.PUT_LINE('3 function-based indexes created for case-insensitive searches');

-- ============================================
-- Verification of Indexes
-- ============================================
DECLARE
    v_index_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_index_count
    FROM user_indexes
    WHERE table_name IN ('CROP_TYPE', 'FARM', 'SENSOR', 'SENSOR_READING', 
                        'RESOURCE_TYPE', 'INVENTORY', 'ALLOCATION_LOG', 
                        'ALERT_LOG', 'AGRI_USER', 'HOLIDAY', 'AUDIT_LOG')
      AND index_type != 'LOB';
    
    DBMS_OUTPUT.PUT_LINE('Total indexes created: ' || v_index_count);
    DBMS_OUTPUT.PUT_LINE('All indexes placed in agrioptima_idx tablespace.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error verifying indexes: ' || SQLERRM);
END;
/

-- ============================================
-- Index Creation Summary
-- ============================================
PROMPT ============================================
PROMPT INDEX CREATION COMPLETE
PROMPT ============================================
PROMPT Total indexes: ~40+ indexes created
PROMPT Tablespace: agrioptima_idx
PROMPT Purpose: Optimize query performance for:
PROMPT   - Time-series data (sensor_reading)
PROMPT   - Foreign key lookups
PROMPT   - Date-based queries
PROMPT   - Audit trail queries (Phase VII)
PROMPT ============================================
