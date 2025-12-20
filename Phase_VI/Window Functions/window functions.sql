-- Window Function 1: Rank farms by sensor activity
SELECT 
    f.farm_id,
    f.farm_name,
    f.location,
    COUNT(s.sensor_id) as sensor_count,
    COUNT(sr.reading_id) as reading_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(sr.reading_id) DESC) as activity_rank,
    RANK() OVER (ORDER BY COUNT(sr.reading_id) DESC) as activity_rank_with_ties,
    DENSE_RANK() OVER (ORDER BY COUNT(sr.reading_id) DESC) as dense_activity_rank
FROM farm f
LEFT JOIN sensor s ON f.farm_id = s.farm_id AND s.status = 'ACTIVE'
LEFT JOIN sensor_reading sr ON s.sensor_id = sr.sensor_id
WHERE f.status = 'ACTIVE'
GROUP BY f.farm_id, f.farm_name, f.location
HAVING COUNT(sr.reading_id) > 0
ORDER BY activity_rank
FETCH FIRST 10 ROWS ONLY;



-- Window Function 2: Compare current reading with previous reading
SELECT 
    sensor_id,
    reading_type,
    reading_value,
    reading_timestamp,
    LAG(reading_value) OVER (
        PARTITION BY sensor_id 
        ORDER BY reading_timestamp
    ) as previous_reading,
    NVL(reading_value - LAG(reading_value) OVER (
        PARTITION BY sensor_id 
        ORDER BY reading_timestamp
    ), 0) as change_from_previous,
    ROW_NUMBER() OVER (
        PARTITION BY sensor_id 
        ORDER BY reading_timestamp
    ) as reading_number
FROM sensor_reading
WHERE sensor_id IN (
    SELECT sensor_id FROM sensor WHERE status = 'ACTIVE' AND ROWNUM <= 3
)
AND quality_flag = 'G'
ORDER BY sensor_id, reading_timestamp
FETCH FIRST 15 ROWS ONLY;


-- Window Function 3: Running total of resource allocations per farm
SELECT 
    farm_id,
    resource_id,
    allocation_timestamp,
    allocated_quantity,
    SUM(allocated_quantity) OVER (
        PARTITION BY farm_id, resource_id 
        ORDER BY allocation_timestamp
    ) as running_total,
    AVG(allocated_quantity) OVER (
        PARTITION BY farm_id, resource_id
    ) as avg_allocation,
    allocated_quantity - AVG(allocated_quantity) OVER (
        PARTITION BY farm_id, resource_id
    ) as deviation_from_avg
FROM allocation_log
WHERE status = 'COMPLETED'
  AND farm_id IN (
      SELECT farm_id FROM farm WHERE status = 'ACTIVE' AND ROWNUM <= 3
  )
ORDER BY farm_id, resource_id, allocation_timestamp
FETCH FIRST 20 ROWS ONLY;


-- Window Function 4: Categorize farms into quartiles by area
SELECT 
    farm_id,
    farm_name,
    total_area_hectares,
    NTILE(4) OVER (ORDER BY total_area_hectares DESC) as area_quartile,
    CASE NTILE(4) OVER (ORDER BY total_area_hectares DESC)
        WHEN 1 THEN 'LARGE'
        WHEN 2 THEN 'MEDIUM_LARGE'
        WHEN 3 THEN 'MEDIUM_SMALL'
        WHEN 4 THEN 'SMALL'
    END as farm_size_category,
    PERCENT_RANK() OVER (ORDER BY total_area_hectares) as area_percentile,
    CUME_DIST() OVER (ORDER BY total_area_hectares) as cumulative_distribution
FROM farm
WHERE status = 'ACTIVE'
  AND total_area_hectares IS NOT NULL
ORDER BY total_area_hectares DESC
FETCH FIRST 15 ROWS ONLY;
