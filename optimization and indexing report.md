# 📂 Phase VIII – Optimization & Indexing

## Overview

This phase focuses on improving the performance of frequently executed queries in the AgriOptima database. 

By identifying high-usage columns and applying strategic indexing, we reduce query cost, improve response time, and prepare the schema for scalability.

## 🔍 Index Strategy

## Indexed Columns

Based on query patterns from Phase VI and VII, the following columns were selected for indexing:

| Table           | Column        | Reason for Indexing                          |
|-----------------|---------------|----------------------------------------------|
| FARM_SECTIONS   | crop_type_id  | Used in joins with CROP_PROFILES             |
| SENSOR_READINGS | section_id    | Used in joins and aggregations               |
| ALLOCATION_LOG  | section_id    | Used in joins and filters                    |
| ALLOCATION_LOG  | resource_id   | Used in joins with RESOURCE_INVENTORY        |
| ALERT_LOG       | alert_type    | Used in filtering and grouping               |

## ⚙️ Index Creation Scripts

```sql

-- FARM_SECTIONS ↔ CROP_PROFILES join
CREATE INDEX idx_farm_crop ON FARM_SECTIONS(crop_type_id);

-- SENSOR_READINGS section lookup
CREATE INDEX idx_sensor_section ON SENSOR_READINGS(section_id);

-- ALLOCATION_LOG joins
CREATE INDEX idx_alloc_section ON ALLOCATION_LOG(section_id);
CREATE INDEX idx_alloc_resource ON ALLOCATION_LOG(resource_id);

-- ALERT_LOG filtering
CREATE INDEX idx_alert_type ON ALERT_LOG(alert_type);

```
---

## 📊 Performance Testing

**Method**:

Used EXPLAIN PLAN and DBMS_XPLAN.DISPLAY to compare query cost before and after indexing.

**Example Query**:

```sql

EXPLAIN PLAN FOR
SELECT c.crop_name, ROUND(AVG(s.nutrient_level_ppm),2) AS avg_nutrient
FROM SENSOR_READINGS s
JOIN FARM_SECTIONS f ON s.section_id = f.section_id
JOIN CROP_PROFILES c ON f.crop_type_id = c.crop_type_id
GROUP BY c.crop_name;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

```

**Observations**

- **Before indexing:** Full table scans on SENSOR_READINGS and FARM_SECTIONS.

- **After indexing:** Index range scans and reduced cost.

- **Query time:** Improved by ~35–50% depending on data volume.

---

## 🧠 Optimization Insights

- Indexes significantly improved performance for joins and filters.

- ALERT_LOG queries now use index range scans for alert_type.

- SENSOR_READINGS aggregations benefit from indexed section_id.

- Future optimization could include:
                                  - Partitioning SENSOR_READINGS by date for large-scale deployments.

                                  - Materialized views for frequently accessed summaries.

---

## ✅ Summary

| Benefit             | Result                                         |
|---------------------|-----------------------------------------------|
| Faster joins        | Reduced cost for multi-table queries          |
| Efficient filtering | Improved performance on alert/resource queries|
| Scalable design     | Schema ready for larger datasets              |

Indexing ensures AgriOptima remains responsive and efficient as data grows, supporting real-time decision-making and analytics.
