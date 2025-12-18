# AgriOptima - Data Dictionary

---

## Table of Contents
1. [Tables Overview](#tables-overview)
2. [Table Definitions](#table-definitions)
3. [Foreign Key Relationships](#foreign-key-relationships)
4. [Constraints Summary](#constraints-summary)

---

## Tables Overview

| Table Name | Description | Rows (Est.) | BI Role |
|------------|-------------|-------------|---------|
| CROP_TYPE | Defines crop types and optimal growing conditions | 50-100 | Dimension |
| FARM | Farm details and registration information | 100-500 | Dimension |
| SENSOR | IoT sensor metadata and installation details | 500-2000 | Dimension |
| SENSOR_READING | Time-series sensor measurements | 1M+ | Fact |
| RESOURCE_TYPE | Resource specifications (water, fertilizer, etc.) | 20-50 | Dimension |
| INVENTORY | Current stock levels per farm per resource | 500-5000 | Dimension/Fact |
| ALLOCATION_LOG | Automated resource allocation records | 10K+ | Fact |
| ALERT_LOG | System-generated alerts and notifications | 5K+ | Fact |
| USER | System users and their roles | 50-200 | Dimension |
| HOLIDAY | Holiday calendar for business rule enforcement | 50-100 | Dimension |
| AUDIT_LOG | Audit trail for DML operations | 10K+ | Fact |

---

## Table Definitions

### 1. CROP_TYPE
Stores crop types and their optimal growing conditions.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| CROP_TYPE_ID | NUMBER(10) | PK, NOT NULL | Unique identifier for crop type |
| CROP_NAME | VARCHAR2(50) | NOT NULL | Name of the crop (e.g., Corn, Wheat, Tomatoes) |
| OPTIMAL_MOISTURE | NUMBER(5,2) | CHECK (0-100) | Optimal soil moisture percentage |
| OPTIMAL_NUTRIENT_LEVEL | NUMBER(5,2) | CHECK (>0) | Optimal nutrient level in soil |
| GROWTH_STAGE | VARCHAR2(20) | DEFAULT 'SEEDLING' | Current growth stage |

### 2. FARM
Contains farm registration and location details.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| FARM_ID | NUMBER(10) | PK, NOT NULL | Unique farm identifier |
| FARM_NAME | VARCHAR2(100) | NOT NULL | Name of the farm |
| LOCATION | VARCHAR2(200) | NOT NULL | Physical location/address |
| CROP_TYPE_ID | NUMBER(10) | FK → CROP_TYPE, NOT NULL | Type of crop cultivated |
| CONTACT_INFO | VARCHAR2(100) | - | Farmer contact details |
| REGISTRATION_DATE | DATE | DEFAULT SYSDATE | Date farm registered in system |

### 3. SENSOR
IoT sensor installation and metadata.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| SENSOR_ID | NUMBER(10) | PK, NOT NULL | Unique sensor identifier |
| FARM_ID | NUMBER(10) | FK → FARM, NOT NULL | Farm where sensor is installed |
| SENSOR_TYPE | VARCHAR2(30) | NOT NULL | Type (Moisture, Nutrient, Temperature, pH) |
| STATUS | VARCHAR2(20) | DEFAULT 'ACTIVE' | Current status (ACTIVE/INACTIVE/FAULTY) |
| INSTALLATION_DATE | DATE | DEFAULT SYSDATE | Date sensor was installed |

### 4. SENSOR_READING
Time-series data from IoT sensors.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| READING_ID | NUMBER(15) | PK, NOT NULL | Unique reading identifier |
| SENSOR_ID | NUMBER(10) | FK → SENSOR, NOT NULL | Sensor that captured reading |
| READING_VALUE | NUMBER(10,2) | NOT NULL | Numerical value of reading |
| READING_TYPE | VARCHAR2(30) | NOT NULL | Type of measurement |
| READING_TIMESTAMP | TIMESTAMP | DEFAULT SYSTIMESTAMP | Time reading was captured |

### 5. RESOURCE_TYPE
Definitions of farm resources and their specifications.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| RESOURCE_ID | NUMBER(10) | PK, NOT NULL | Unique resource identifier |
| RESOURCE_NAME | VARCHAR2(50) | NOT NULL | Name (Water, Fertilizer-A, Pesticide-B, etc.) |
| UNIT | VARCHAR2(20) | NOT NULL | Measurement unit (Liters, Kg, Units) |
| OPTIMAL_LEVEL | NUMBER(10,2) | CHECK (>0) | Optimal quantity for standard farm |
| REORDER_LEVEL | NUMBER(10,2) | CHECK (>0) | Minimum level before reorder alert |

### 6. INVENTORY
Current stock levels of resources per farm.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| INVENTORY_ID | NUMBER(10) | PK, NOT NULL | Unique inventory record ID |
| FARM_ID | NUMBER(10) | FK → FARM, NOT NULL | Farm owning inventory |
| RESOURCE_ID | NUMBER(10) | FK → RESOURCE_TYPE, NOT NULL | Type of resource in inventory |
| CURRENT_QUANTITY | NUMBER(10,2) | DEFAULT 0, CHECK (>=0) | Current stock level |
| LAST_REPLENISH_DATE | DATE | - | Date last restocked |

### 7. ALLOCATION_LOG
Records of automated resource allocations.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| ALLOCATION_ID | NUMBER(15) | PK, NOT NULL | Unique allocation identifier |
| FARM_ID | NUMBER(10) | FK → FARM, NOT NULL | Farm receiving allocation |
| RESOURCE_ID | NUMBER(10) | FK → RESOURCE_TYPE, NOT NULL | Resource being allocated |
| ALLOCATED_QUANTITY | NUMBER(10,2) | CHECK (>0) | Quantity allocated |
| ALLOCATION_TIMESTAMP | TIMESTAMP | DEFAULT SYSTIMESTAMP | Time of allocation |
| USER_ID | NUMBER(10) | FK → USER, NOT NULL | User who approved allocation |
| STATUS | VARCHAR2(20) | DEFAULT 'COMPLETED' | Status (PENDING/COMPLETED/FAILED) |

### 8. ALERT_LOG
System-generated alerts for various conditions.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| ALERT_ID | NUMBER(15) | PK, NOT NULL | Unique alert identifier |
| FARM_ID | NUMBER(10) | FK → FARM, NOT NULL | Farm where alert triggered |
| ALERT_TYPE | VARCHAR2(30) | NOT NULL | Type (LOW_STOCK, HIGH_MOISTURE, etc.) |
| ALERT_MESSAGE | VARCHAR2(200) | NOT NULL | Detailed alert message |
| ALERT_TIMESTAMP | TIMESTAMP | DEFAULT SYSTIMESTAMP | Time alert generated |
| STATUS | VARCHAR2(20) | DEFAULT 'ACTIVE' | Status (ACTIVE/ACKNOWLEDGED/RESOLVED) |

### 9. USER
System users with authentication and role information.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| USER_ID | NUMBER(10) | PK, NOT NULL | Unique user identifier |
| USERNAME | VARCHAR2(50) | UNIQUE, NOT NULL | Login username |
| ROLE | VARCHAR2(30) | DEFAULT 'FARMER' | Role (FARMER/MANAGER/ADMIN) |
| EMAIL | VARCHAR2(100) | NOT NULL | User email address |
| CREATED_AT | DATE | DEFAULT SYSDATE | Account creation date |

### 10. HOLIDAY
Holiday calendar for business rule enforcement.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| HOLIDAY_DATE | DATE | PK, NOT NULL | Date of holiday |
| HOLIDAY_NAME | VARCHAR2(100) | NOT NULL | Name/description of holiday |

### 11. AUDIT_LOG
Audit trail for compliance and security.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| AUDIT_ID | NUMBER(15) | PK, NOT NULL | Unique audit record ID |
| TABLE_NAME | VARCHAR2(50) | NOT NULL | Table where DML occurred |
| ACTION_TYPE | VARCHAR2(10) | CHECK (INSERT/UPDATE/DELETE) | Type of DML operation |
| ACTION_TIMESTAMP | TIMESTAMP | DEFAULT SYSTIMESTAMP | Time of action |
| USER_ID | NUMBER(10) | FK → USER, NOT NULL | User who performed action |
| DETAILS | VARCHAR2(500) | - | Additional details/values |

---

## Foreign Key Relationships

| Foreign Key Name | From Table | From Column | To Table | To Column | Relationship |
|-----------------|------------|-------------|----------|-----------|--------------|
| FK_FARM_CROP | FARM | CROP_TYPE_ID | CROP_TYPE | CROP_TYPE_ID | 1:M |
| FK_SENSOR_FARM | SENSOR | FARM_ID | FARM | FARM_ID | 1:M |
| FK_READING_SENSOR | SENSOR_READING | SENSOR_ID | SENSOR | SENSOR_ID | 1:M |
| FK_INVENTORY_FARM | INVENTORY | FARM_ID | FARM | FARM_ID | 1:M |
| FK_INVENTORY_RESOURCE | INVENTORY | RESOURCE_ID | RESOURCE_TYPE | RESOURCE_ID | 1:M |
| FK_ALLOCATION_FARM | ALLOCATION_LOG | FARM_ID | FARM | FARM_ID | 1:M |
| FK_ALLOCATION_RESOURCE | ALLOCATION_LOG | RESOURCE_ID | RESOURCE_TYPE | RESOURCE_ID | 1:M |
| FK_ALLOCATION_USER | ALLOCATION_LOG | USER_ID | USER | USER_ID | 1:M |
| FK_ALERT_FARM | ALERT_LOG | FARM_ID | FARM | FARM_ID | 1:M |
| FK_AUDIT_USER | AUDIT_LOG | USER_ID | USER | USER_ID | 1:M |

---

## Constraints Summary

### Primary Keys:
- CROP_TYPE: CROP_TYPE_ID
- FARM: FARM_ID
- SENSOR: SENSOR_ID
- SENSOR_READING: READING_ID
- RESOURCE_TYPE: RESOURCE_ID
- INVENTORY: INVENTORY_ID
- ALLOCATION_LOG: ALLOCATION_ID
- ALERT_LOG: ALERT_ID
- USER: USER_ID
- HOLIDAY: HOLIDAY_DATE
- AUDIT_LOG: AUDIT_ID

### Unique Constraints:
- USER: USERNAME (must be unique)
- USER: EMAIL (business rule, though not enforced by DB)

### Check Constraints:
- CROP_TYPE: OPTIMAL_MOISTURE BETWEEN 0 AND 100
- CROP_TYPE: OPTIMAL_NUTRIENT_LEVEL > 0
- RESOURCE_TYPE: OPTIMAL_LEVEL > 0
- RESOURCE_TYPE: REORDER_LEVEL > 0
- INVENTORY: CURRENT_QUANTITY >= 0
- ALLOCATION_LOG: ALLOCATED_QUANTITY > 0
- AUDIT_LOG: ACTION_TYPE IN ('INSERT', 'UPDATE', 'DELETE')

### Default Values:
- CROP_TYPE: GROWTH_STAGE = 'SEEDLING'
- SENSOR: STATUS = 'ACTIVE'
- INVENTORY: CURRENT_QUANTITY = 0
- ALLOCATION_LOG: STATUS = 'COMPLETED'
- ALERT_LOG: STATUS = 'ACTIVE'
- USER: ROLE = 'FARMER'

---
