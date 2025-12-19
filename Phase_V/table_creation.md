

```sql
-- ============================================
-- CREATE TABLES for AgriOptima Enhanced BI
-- Phase V: Table Implementation
-- Student: [Your Name]
-- Student ID: [Your ID]
-- Date: December 19, 2024
-- ============================================

-- ============================================
-- 1. CROP_TYPE Table
-- ============================================
CREATE TABLE crop_type (
    crop_type_id NUMBER(10) CONSTRAINT pk_crop_type PRIMARY KEY,
    crop_name VARCHAR2(50) CONSTRAINT nn_crop_name NOT NULL,
    optimal_moisture NUMBER(5,2) CONSTRAINT chk_optimal_moisture CHECK (optimal_moisture BETWEEN 0 AND 100),
    optimal_nutrient_level NUMBER(5,2) CONSTRAINT chk_optimal_nutrient CHECK (optimal_nutrient_level > 0),
    growth_stage VARCHAR2(20) DEFAULT 'SEEDLING',
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT unq_crop_name UNIQUE (crop_name)
) TABLESPACE agrioptima_data;

-- ============================================
-- 2. FARM Table
-- ============================================
CREATE TABLE farm (
    farm_id NUMBER(10) CONSTRAINT pk_farm PRIMARY KEY,
    farm_name VARCHAR2(100) CONSTRAINT nn_farm_name NOT NULL,
    location VARCHAR2(200) CONSTRAINT nn_farm_location NOT NULL,
    crop_type_id NUMBER(10) CONSTRAINT nn_crop_type_id NOT NULL,
    contact_info VARCHAR2(100),
    registration_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    total_area_hectares NUMBER(8,2),
    CONSTRAINT fk_farm_crop_type FOREIGN KEY (crop_type_id) REFERENCES crop_type(crop_type_id),
    CONSTRAINT chk_farm_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
) TABLESPACE agrioptima_data;

-- ============================================
-- 3. SENSOR Table
-- ============================================
CREATE TABLE sensor (
    sensor_id NUMBER(10) CONSTRAINT pk_sensor PRIMARY KEY,
    farm_id NUMBER(10) CONSTRAINT nn_sensor_farm_id NOT NULL,
    sensor_type VARCHAR2(30) CONSTRAINT nn_sensor_type NOT NULL,
    sensor_model VARCHAR2(50),
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    installation_date DATE DEFAULT SYSDATE,
    last_calibration_date DATE,
    latitude NUMBER(10,6),
    longitude NUMBER(10,6),
    CONSTRAINT fk_sensor_farm FOREIGN KEY (farm_id) REFERENCES farm(farm_id),
    CONSTRAINT chk_sensor_type CHECK (sensor_type IN ('MOISTURE', 'TEMPERATURE', 'PH', 'NUTRIENT', 'HUMIDITY', 'LIGHT')),
    CONSTRAINT chk_sensor_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'FAULTY'))
) TABLESPACE agrioptima_data;

-- ============================================
-- 4. SENSOR_READING Table
-- ============================================
CREATE TABLE sensor_reading (
    reading_id NUMBER(15) CONSTRAINT pk_sensor_reading PRIMARY KEY,
    sensor_id NUMBER(10) CONSTRAINT nn_reading_sensor_id NOT NULL,
    reading_value NUMBER(10,2) CONSTRAINT nn_reading_value NOT NULL,
    reading_type VARCHAR2(30) CONSTRAINT nn_reading_type NOT NULL,
    reading_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    unit VARCHAR2(10) DEFAULT 'UNIT',
    quality_flag VARCHAR2(1) DEFAULT 'G',
    CONSTRAINT fk_reading_sensor FOREIGN KEY (sensor_id) REFERENCES sensor(sensor_id),
    CONSTRAINT chk_quality_flag CHECK (quality_flag IN ('G', 'B', 'S')) -- Good, Bad, Suspect
) TABLESPACE agrioptima_data;

-- ============================================
-- 5. RESOURCE_TYPE Table
-- ============================================
CREATE TABLE resource_type (
    resource_id NUMBER(10) CONSTRAINT pk_resource_type PRIMARY KEY,
    resource_name VARCHAR2(50) CONSTRAINT nn_resource_name NOT NULL,
    unit VARCHAR2(20) CONSTRAINT nn_resource_unit NOT NULL,
    optimal_level NUMBER(10,2) CONSTRAINT chk_optimal_level CHECK (optimal_level > 0),
    reorder_level NUMBER(10,2) CONSTRAINT chk_reorder_level CHECK (reorder_level > 0),
    unit_cost NUMBER(12,2),
    supplier VARCHAR2(100),
    category VARCHAR2(30) DEFAULT 'FERTILIZER',
    CONSTRAINT unq_resource_name UNIQUE (resource_name),
    CONSTRAINT chk_category CHECK (category IN ('WATER', 'FERTILIZER', 'PESTICIDE', 'EQUIPMENT', 'OTHER'))
) TABLESPACE agrioptima_data;

-- ============================================
-- 6. INVENTORY Table
-- ============================================
CREATE TABLE inventory (
    inventory_id NUMBER(10) CONSTRAINT pk_inventory PRIMARY KEY,
    farm_id NUMBER(10) CONSTRAINT nn_inv_farm_id NOT NULL,
    resource_id NUMBER(10) CONSTRAINT nn_inv_resource_id NOT NULL,
    current_quantity NUMBER(10,2) DEFAULT 0 CONSTRAINT chk_current_qty CHECK (current_quantity >= 0),
    last_replenish_date DATE,
    next_reorder_date DATE,
    storage_location VARCHAR2(50),
    batch_number VARCHAR2(30),
    CONSTRAINT fk_inv_farm FOREIGN KEY (farm_id) REFERENCES farm(farm_id),
    CONSTRAINT fk_inv_resource FOREIGN KEY (resource_id) REFERENCES resource_type(resource_id),
    CONSTRAINT unq_farm_resource UNIQUE (farm_id, resource_id) -- One inventory record per resource per farm
) TABLESPACE agrioptima_data;

-- ============================================
-- 7. ALLOCATION_LOG Table
-- ============================================
CREATE TABLE allocation_log (
    allocation_id NUMBER(15) CONSTRAINT pk_allocation PRIMARY KEY,
    farm_id NUMBER(10) CONSTRAINT nn_alloc_farm_id NOT NULL,
    resource_id NUMBER(10) CONSTRAINT nn_alloc_resource_id NOT NULL,
    allocated_quantity NUMBER(10,2) CONSTRAINT chk_alloc_qty CHECK (allocated_quantity > 0),
    allocation_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    user_id NUMBER(10) CONSTRAINT nn_alloc_user_id NOT NULL,
    status VARCHAR2(20) DEFAULT 'COMPLETED',
    allocation_type VARCHAR2(20) DEFAULT 'AUTOMATED',
    reason VARCHAR2(200),
    CONSTRAINT fk_alloc_farm FOREIGN KEY (farm_id) REFERENCES farm(farm_id),
    CONSTRAINT fk_alloc_resource FOREIGN KEY (resource_id) REFERENCES resource_type(resource_id),
    CONSTRAINT chk_alloc_status CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED')),
    CONSTRAINT chk_alloc_type CHECK (allocation_type IN ('AUTOMATED', 'MANUAL', 'EMERGENCY'))
) TABLESPACE agrioptima_data;

-- ============================================
-- 8. ALERT_LOG Table
-- ============================================
CREATE TABLE alert_log (
    alert_id NUMBER(15) CONSTRAINT pk_alert PRIMARY KEY,
    farm_id NUMBER(10) CONSTRAINT nn_alert_farm_id NOT NULL,
    alert_type VARCHAR2(30) CONSTRAINT nn_alert_type NOT NULL,
    alert_message VARCHAR2(200) CONSTRAINT nn_alert_message NOT NULL,
    alert_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    severity VARCHAR2(10) DEFAULT 'MEDIUM',
    acknowledged_by NUMBER(10),
    acknowledged_date TIMESTAMP,
    CONSTRAINT fk_alert_farm FOREIGN KEY (farm_id) REFERENCES farm(farm_id),
    CONSTRAINT chk_alert_status CHECK (status IN ('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED', 'DISMISSED')),
    CONSTRAINT chk_alert_severity CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_alert_type CHECK (alert_type IN ('LOW_STOCK', 'HIGH_MOISTURE', 'LOW_MOISTURE', 
                                                    'HIGH_TEMP', 'LOW_TEMP', 'PEST_DETECTION', 
                                                    'EQUIPMENT_FAILURE', 'SCHEDULE_MISSED'))
) TABLESPACE agrioptima_data;

-- ============================================
-- 9. AGRI_USER Table (avoid Oracle reserved word USER)
-- ============================================
CREATE TABLE agri_user (
    user_id NUMBER(10) CONSTRAINT pk_user PRIMARY KEY,
    username VARCHAR2(50) CONSTRAINT nn_username NOT NULL,
    password_hash VARCHAR2(100) CONSTRAINT nn_password NOT NULL,
    role VARCHAR2(30) DEFAULT 'FARMER',
    email VARCHAR2(100) CONSTRAINT nn_email NOT NULL,
    full_name VARCHAR2(100),
    phone_number VARCHAR2(20),
    created_at DATE DEFAULT SYSDATE,
    last_login TIMESTAMP,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    farm_id NUMBER(10), -- Optional: if user is associated with specific farm
    CONSTRAINT unq_username UNIQUE (username),
    CONSTRAINT unq_email UNIQUE (email),
    CONSTRAINT fk_user_farm FOREIGN KEY (farm_id) REFERENCES farm(farm_id),
    CONSTRAINT chk_user_role CHECK (role IN ('FARMER', 'MANAGER', 'ADMIN', 'AGROLOGIST', 'VIEWER')),
    CONSTRAINT chk_user_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
) TABLESPACE agrioptima_data;

-- ============================================
-- 10. HOLIDAY Table
-- ============================================
CREATE TABLE holiday (
    holiday_date DATE CONSTRAINT pk_holiday PRIMARY KEY,
    holiday_name VARCHAR2(100) CONSTRAINT nn_holiday_name NOT NULL,
    country VARCHAR2(50) DEFAULT 'RWANDA',
    holiday_type VARCHAR2(30) DEFAULT 'PUBLIC',
    CONSTRAINT chk_holiday_type CHECK (holiday_type IN ('PUBLIC', 'RELIGIOUS', 'NATIONAL', 'OBSERVANCE'))
) TABLESPACE agrioptima_data;

-- ============================================
-- 11. AUDIT_LOG Table
-- ============================================
CREATE TABLE audit_log (
    audit_id NUMBER(15) CONSTRAINT pk_audit PRIMARY KEY,
    table_name VARCHAR2(50) CONSTRAINT nn_audit_table NOT NULL,
    action_type VARCHAR2(10) CONSTRAINT nn_audit_action NOT NULL,
    action_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    user_id NUMBER(10) CONSTRAINT nn_audit_user_id NOT NULL,
    record_id VARCHAR2(50), -- Can store PK of modified record
    old_values CLOB,
    new_values CLOB,
    ip_address VARCHAR2(45),
    CONSTRAINT chk_audit_action CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES agri_user(user_id)
) TABLESPACE agrioptima_data;

-- ============================================
-- END OF TABLE CREATION
-- ============================================
DBMS_OUTPUT.PUT_LINE('All 11 tables created successfully in agrioptima_data tablespace.');
