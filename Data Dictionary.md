# 📖 AgriOptima Data Dictionary

## 1. CROP_PROFILES
| Column              | Data Type     | Key | Description |
|---------------------|--------------|-----|-------------|
| crop_type_id        | NUMBER       | PK  | Unique identifier for each crop type |
| crop_name           | VARCHAR2(50) |     | Name of the crop (e.g., Maize, Beans) |
| min_moisture_pct    | NUMBER       |     | Minimum soil moisture percentage required |
| optimal_nutrient_ppm| NUMBER       |     | Optimal nutrient level in ppm |
| pest_threshold      | NUMBER       |     | Pest risk threshold value |

---

## 2. FARM_SECTIONS
| Column              | Data Type     | Key | Description |
|---------------------|--------------|-----|-------------|
| section_id          | NUMBER       | PK  | Unique identifier for each farm section |
| crop_type_id        | NUMBER       | FK  | References CROP_PROFILES.crop_type_id |
| section_area_sqm    | NUMBER       |     | Area of the section in square meters |
| current_status      | VARCHAR2(50) |     | Current operational status (Active, Idle, Maintenance) |

---

## 3. SENSOR_READINGS
| Column              | Data Type     | Key | Description |
|---------------------|--------------|-----|-------------|
| reading_id          | NUMBER       | PK  | Unique identifier for each sensor reading |
| section_id          | NUMBER       | FK  | References FARM_SECTIONS.section_id |
| reading_timestamp   | DATE         |     | Date and time of the reading |
| soil_moisture_pct   | NUMBER       |     | Soil moisture percentage recorded |
| nutrient_level_ppm  | NUMBER       |     | Nutrient level in ppm recorded |

---

## 4. RESOURCE_INVENTORY
| Column              | Data Type     | Key | Description |
|---------------------|--------------|-----|-------------|
| resource_id         | NUMBER       | PK  | Unique identifier for each resource |
| resource_name       | VARCHAR2(50) |     | Name of the resource (e.g., Fertilizer A) |
| current_stock_units | NUMBER       |     | Current stock available in units |
| reorder_threshold   | NUMBER       |     | Minimum stock level before reorder is triggered |

---

## 5. ALLOCATION_LOG
| Column              | Data Type     | Key | Description |
|---------------------|--------------|-----|-------------|
| log_id              | NUMBER       | PK  | Unique identifier for each allocation log |
| section_id          | NUMBER       | FK  | References FARM_SECTIONS.section_id |
| resource_id         | NUMBER       | FK  | References RESOURCE_INVENTORY.resource_id |
| quantity_applied    | NUMBER       |     | Quantity of resource applied |
| allocation_timestamp| DATE         |     | Date and time of resource allocation |

---

## 6. ALERT_LOG
| Column              | Data Type     | Key | Description |
|---------------------|--------------|-----|-------------|
| alert_id            | NUMBER       | PK  | Unique identifier for each alert |
| alert_timestamp     | DATE         |     | Date and time of the alert |
| alert_type          | VARCHAR2(50) |     | Type of alert (Moisture Low, Nutrient High, Pest Risk) |
| message_text        | VARCHAR2(200)|     | Detailed message describing the alert |

---

## 7. HOLIDAYS
| Column              | Data Type     | Key | Description |
|---------------------|--------------|-----|-------------|
| holiday_date        | DATE         | PK  | Date of the holiday |
| holiday_name        | VARCHAR2(100)|     | Name of the holiday |

---

## 🔑 Notes
- **Schema:** RUKUNDO  
- **Database:** AgriOptima  
- **Foreign Key Relationships:**
  - FARM_SECTIONS → CROP_PROFILES  
  - SENSOR_READINGS → FARM_SECTIONS  
  - ALLOCATION_LOG → FARM_SECTIONS, RESOURCE_INVENTORY  
- **Assumptions:** Each farm section grows one crop type at a time; sensor readings are timestamped; alerts are generated when thresholds are exceeded; holidays block scheduling.

