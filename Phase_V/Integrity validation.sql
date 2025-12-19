-- 1. Data Integrity Verification Queries


-- Check foreign key relationships
SELECT 'Farm-CropType' as check_name, COUNT(*) as violations
FROM farm f
WHERE NOT EXISTS (SELECT 1 FROM crop_type c WHERE c.crop_type_id = f.crop_type_id)

UNION ALL

SELECT 'Sensor-Farm', COUNT(*)
FROM sensor s
WHERE NOT EXISTS (SELECT 1 FROM farm f WHERE f.farm_id = s.farm_id)

UNION ALL

SELECT 'SensorReading-Sensor', COUNT(*)
FROM sensor_reading sr
WHERE NOT EXISTS (SELECT 1 FROM sensor s WHERE s.sensor_id = sr.sensor_id)

UNION ALL

SELECT 'Inventory-Farm', COUNT(*)
FROM inventory i
WHERE NOT EXISTS (SELECT 1 FROM farm f WHERE f.farm_id = i.farm_id)

UNION ALL

SELECT 'Inventory-Resource', COUNT(*)
FROM inventory i
WHERE NOT EXISTS (SELECT 1 FROM resource_type r WHERE r.resource_id = i.resource_id)

UNION ALL

SELECT 'Allocation-Farm', COUNT(*)
FROM allocation_log a
WHERE NOT EXISTS (SELECT 1 FROM farm f WHERE f.farm_id = a.farm_id)

UNION ALL

SELECT 'Allocation-Resource', COUNT(*)
FROM allocation_log a
WHERE NOT EXISTS (SELECT 1 FROM resource_type r WHERE r.resource_id = a.resource_id)

UNION ALL

SELECT 'Allocation-User', COUNT(*)
FROM allocation_log a
WHERE NOT EXISTS (SELECT 1 FROM agri_user u WHERE u.user_id = a.user_id)

UNION ALL

SELECT 'Alert-Farm', COUNT(*)
FROM alert_log al
WHERE NOT EXISTS (SELECT 1 FROM farm f WHERE f.farm_id = al.farm_id)

UNION ALL

SELECT 'User-Farm', COUNT(*)
FROM agri_user u
WHERE u.farm_id IS NOT NULL 
  AND NOT EXISTS (SELECT 1 FROM farm f WHERE f.farm_id = u.farm_id);
  
