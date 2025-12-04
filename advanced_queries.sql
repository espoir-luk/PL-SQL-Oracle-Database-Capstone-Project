-- =========================================================
-- AgriOptima Advanced Queries
-- Author: Rukundo
-- Purpose: Demonstrate analytics, subqueries, and multi-table joins
-- =========================================================

-- 1. Sections Above Average Moisture
-- Find farm sections whose average soil moisture is higher than the overall average
SELECT section_id, AVG(soil_moisture_pct) AS avg_moisture
FROM SENSOR_READINGS
GROUP BY section_id
HAVING AVG(soil_moisture_pct) > (
  SELECT AVG(soil_moisture_pct) FROM SENSOR_READINGS
);

-- 2. Top 3 Resources by Usage
-- Rank resources based on total allocations
SELECT resource_name, SUM(quantity_applied) AS total_used
FROM ALLOCATION_LOG a
JOIN RESOURCE_INVENTORY r ON a.resource_id = r.resource_id
GROUP BY resource_name
ORDER BY total_used DESC
FETCH FIRST 3 ROWS ONLY;

-- 3. Sections with Frequent Alerts
-- Identify sections that triggered more than 5 alerts
SELECT section_id, COUNT(*) AS alert_count
FROM ALERT_LOG al
JOIN FARM_SECTIONS fs ON al.message_text LIKE '%Section ' || fs.section_id || '%'
GROUP BY section_id
HAVING COUNT(*) > 5;

-- 4. Holiday-Aware Resource Planning
-- Check allocations that happened on holidays
SELECT h.holiday_name, a.section_id, a.resource_id, a.quantity_applied
FROM ALLOCATION_LOG a
JOIN HOLIDAYS h ON TRUNC(a.allocation_timestamp) = h.holiday_date;

-- 5. Crop Efficiency Report
-- Compare average nutrient levels per crop type
SELECT c.crop_name, ROUND(AVG(s.nutrient_level_ppm),2) AS avg_nutrient
FROM SENSOR_READINGS s
JOIN FARM_SECTIONS f ON s.section_id = f.section_id
JOIN CROP_PROFILES c ON f.crop_type_id = c.crop_type_id
GROUP BY c.crop_name;

-- 6. Resource Reorder Alerts
-- Find resources that are below their reorder threshold
SELECT resource_name, current_stock_units, reorder_threshold
FROM RESOURCE_INVENTORY
WHERE current_stock_units < reorder_threshold;

-- 7. Sensor Anomaly Detection
-- Find readings where moisture is below crop minimum OR nutrients below optimal
SELECT s.section_id, s.reading_timestamp, s.soil_moisture_pct, s.nutrient_level_ppm, c.crop_name
FROM SENSOR_READINGS s
JOIN FARM_SECTIONS f ON s.section_id = f.section_id
JOIN CROP_PROFILES c ON f.crop_type_id = c.crop_type_id
WHERE s.soil_moisture_pct < c.min_moisture_pct
   OR s.nutrient_level_ppm < c.optimal_nutrient_ppm;
