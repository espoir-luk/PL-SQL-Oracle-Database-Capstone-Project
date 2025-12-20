  -- A. Basic retrieval (SELECT *)
SELECT * FROM farm WHERE ROWNUM <= 5;

-- B. Joins (multi-table queries)
SELECT f.farm_name, f.location, c.crop_name, s.sensor_type, s.status
FROM farm f
JOIN crop_type c ON f.crop_type_id = c.crop_type_id
JOIN sensor s ON f.farm_id = s.farm_id
WHERE f.status = 'ACTIVE'
  AND s.status = 'ACTIVE'
  AND ROWNUM <= 10;

-- C. Aggregations (GROUP BY)
SELECT 
    c.crop_name,
    COUNT(f.farm_id) as farm_count,
    AVG(f.total_area_hectares) as avg_area,
    SUM(f.total_area_hectares) as total_area
FROM farm f
JOIN crop_type c ON f.crop_type_id = c.crop_type_id
WHERE f.status = 'ACTIVE'
GROUP BY c.crop_name
ORDER BY farm_count DESC;

-- D. Subqueries
SELECT 
    farm_name,
    location,
    total_area_hectares,
    (SELECT COUNT(*) FROM sensor WHERE farm_id = f.farm_id) as sensor_count,
    (SELECT COUNT(*) FROM inventory WHERE farm_id = f.farm_id) as inventory_items
FROM farm f
WHERE f.status = 'ACTIVE'
  AND ROWNUM <= 10;
