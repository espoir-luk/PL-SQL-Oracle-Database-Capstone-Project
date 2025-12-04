-- =========================================================
-- AgriOptima Database Schema
-- Author: Rukundo
-- Purpose: Create all tables in USERS tablespace
-- =========================================================

-- CROP_PROFILES
CREATE TABLE CROP_PROFILES (
  crop_type_id NUMBER PRIMARY KEY,
  crop_name VARCHAR2(50) NOT NULL,
  min_moisture_pct NUMBER NOT NULL,
  optimal_nutrient_ppm NUMBER NOT NULL,
  pest_threshold NUMBER NOT NULL
) TABLESPACE USERS;

-- FARM_SECTIONS
CREATE TABLE FARM_SECTIONS (
  section_id NUMBER PRIMARY KEY,
  crop_type_id NUMBER NOT NULL,
  section_area_sqm NUMBER NOT NULL,
  current_status VARCHAR2(50),
  CONSTRAINT fk_crop FOREIGN KEY (crop_type_id)
    REFERENCES CROP_PROFILES(crop_type_id)
) TABLESPACE USERS;

-- SENSOR_READINGS
CREATE TABLE SENSOR_READINGS (
  reading_id NUMBER PRIMARY KEY,
  section_id NUMBER NOT NULL,
  reading_timestamp DATE NOT NULL,
  soil_moisture_pct NUMBER,
  nutrient_level_ppm NUMBER,
  CONSTRAINT fk_section FOREIGN KEY (section_id)
    REFERENCES FARM_SECTIONS(section_id)
) TABLESPACE USERS;

-- RESOURCE_INVENTORY
CREATE TABLE RESOURCE_INVENTORY (
  resource_id NUMBER PRIMARY KEY,
  resource_name VARCHAR2(50) NOT NULL,
  current_stock_units NUMBER NOT NULL,
  reorder_threshold NUMBER NOT NULL
) TABLESPACE USERS;

-- ALLOCATION_LOG
CREATE TABLE ALLOCATION_LOG (
  log_id NUMBER PRIMARY KEY,
  section_id NUMBER NOT NULL,
  resource_id NUMBER NOT NULL,
  quantity_applied NUMBER NOT NULL,
  allocation_timestamp DATE NOT NULL,
  CONSTRAINT fk_alloc_section FOREIGN KEY (section_id)
    REFERENCES FARM_SECTIONS(section_id),
  CONSTRAINT fk_alloc_resource FOREIGN KEY (resource_id)
    REFERENCES RESOURCE_INVENTORY(resource_id)
) TABLESPACE USERS;

-- ALERT_LOG
CREATE TABLE ALERT_LOG (
  alert_id NUMBER PRIMARY KEY,
  alert_timestamp DATE NOT NULL,
  alert_type VARCHAR2(50) NOT NULL,
  message_text VARCHAR2(200) NOT NULL
) TABLESPACE USERS;

-- HOLIDAYS
CREATE TABLE HOLIDAYS (
  holiday_date DATE PRIMARY KEY,
  holiday_name VARCHAR2(100) NOT NULL
) TABLESPACE USERS;
