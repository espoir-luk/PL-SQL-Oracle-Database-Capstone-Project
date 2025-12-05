# 📂 Phase VII – PL/SQL Programming

## Overview

Phase VII demonstrates how the AgriOptima database can react dynamically to business rules using PL/SQL. This includes stored procedures, 
functions, and triggers that automate alerts, enforce integrity, and provide reusable calculations.

**1. Procedure:** check_moisture_alerts

```sql

CREATE OR REPLACE PROCEDURE check_moisture_alerts IS
BEGIN
  FOR rec IN (
    SELECT s.section_id, s.reading_timestamp, s.soil_moisture_pct, c.min_moisture_pct, c.crop_name
    FROM SENSOR_READINGS s
    JOIN FARM_SECTIONS f ON s.section_id = f.section_id
    JOIN CROP_PROFILES c ON f.crop_type_id = c.crop_type_id
    WHERE s.soil_moisture_pct < c.min_moisture_pct
  ) LOOP
    INSERT INTO ALERT_LOG (alert_id, alert_timestamp, alert_type, message_text)
    VALUES (
      ALERT_LOG_SEQ.NEXTVAL,
      rec.reading_timestamp,
      'Moisture Alert',
      'Section ' || rec.section_id || ' (' || rec.crop_name || ') moisture below threshold'
    );
  END LOOP;
END;
/

```
