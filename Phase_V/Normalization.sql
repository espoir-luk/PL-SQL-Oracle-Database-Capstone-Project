# Normalization Justification (3NF)

## 1NF Compliance
✅ **Atomic values** – All columns contain single, indivisible values  
✅ **No repeating groups** – Each table row represents one entity instance  
✅ **Unique column names** – No duplicate column names across tables  

**Example:**  
- `SENSOR_READING` stores one reading per row, not comma-separated values

## 2NF Compliance
✅ **No partial dependencies** – All non-key attributes depend on the entire primary key  

**Example:**  
- `INVENTORY` PK is `INVENTORY_ID` (single column)  
- All attributes (`CURRENT_QUANTITY`, `LAST_REPLENISH_DATE`) depend on full PK

## 3NF Compliance
✅ **No transitive dependencies** – No non-key attribute depends on another non-key attribute  

**Example:**  
- In `FARM`: `LOCATION` doesn't determine `CONTACT_INFO`  
- In `USER`: `EMAIL` doesn't determine `ROLE`

## Key Normalization Decisions

| Table | Normalization Applied | Benefit |
|-------|----------------------|---------|
| FARM | Separated from CROP_TYPE | Eliminates crop data duplication |
| INVENTORY | Separated from RESOURCE_TYPE | Centralizes resource specifications |
| ALLOCATION_LOG | Separate from USER | Avoids user data repetition |
| SENSOR_READING | Atomic timestamp values | Enables time-series analysis |

## Denormalization Considerations (for BI)
- **Base schema:** Strict 3NF for OLTP operations  
- **Materialized views:** May be added for reporting performance  
- **Aggregate tables:** Optional for dashboard optimization

## Verification
All tables satisfy:
- ✅ 1NF: Atomic columns, no repeating groups  
- ✅ 2NF: No partial dependencies  
- ✅ 3NF: No transitive dependencies

*Design optimized for data integrity, minimal redundancy, and BI readiness.*
