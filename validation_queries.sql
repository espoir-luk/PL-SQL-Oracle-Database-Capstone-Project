-- Validate FARM_SECTIONS join with CROP_PROFILES
SELECT f.section_id, f.section_area_sqm, c.crop_name
FROM FARM_SECTIONS f
JOIN CROP_PROFILES c ON f.crop_type_id = c.crop_type_id;

-- Validate SENSOR_READINGS count per section
SELECT section_id, COUNT(*) AS reading_count
FROM SENSOR_READINGS
GROUP BY section_id;

-- Validate RESOURCE usage totals
SELECT r.resource_name, SUM(a.quantity_applied) AS total_used
FROM ALLOCATION_LOG a
JOIN RESOURCE_INVENTORY r ON a.resource_id = r.resource_id
GROUP BY r.resource_name;

-- Validate ALERT_LOG by type
SELECT alert_type, COUNT(*) AS alert_count
FROM ALERT_LOG
GROUP BY alert_type;

-- Validate HOLIDAYS lookup
SELECT holiday_name
FROM HOLIDAYS
WHERE holiday_date = TO_DATE('25-DEC-2025','DD-MON-YYYY');
