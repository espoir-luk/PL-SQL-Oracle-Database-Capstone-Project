# 📂 Phase VII – PL/SQL Programming

## Overview

Phase VII demonstrates how the AgriOptima database can react dynamically to business rules using PL/SQL. This includes stored procedures, 
functions, and triggers that automate alerts, enforce integrity, and provide reusable calculations.

---

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

**Explanation**:

- Loops through sensor readings where moisture is below the crop’s minimum threshold.

- Inserts a new alert into ALERT_LOG using a sequence (ALERT_LOG_SEQ).

- Automates detection of crop stress conditions.

---

**2. Function:** resource_efficiency

```sql

CREATE OR REPLACE FUNCTION resource_efficiency(p_section_id NUMBER)
RETURN NUMBER IS
  avg_usage NUMBER;
BEGIN
  SELECT AVG(quantity_applied)
  INTO avg_usage
  FROM ALLOCATION_LOG
  WHERE section_id = p_section_id;

  RETURN NVL(avg_usage,0);
END;
/

```

**Explanation**:

- Accepts a section ID as input.

- Calculates the average resource usage for that section.

- Returns 0 if no allocations exist.

- Provides a reusable metric for efficiency analysis.

---

**3. Trigger:** trg_update_inventory

```sql

CREATE OR REPLACE TRIGGER trg_update_inventory
AFTER INSERT ON ALLOCATION_LOG
FOR EACH ROW
BEGIN
  UPDATE RESOURCE_INVENTORY
  SET current_stock_units = current_stock_units - :NEW.quantity_applied
  WHERE resource_id = :NEW.resource_id;
END;
/

```

**Explanation**:

- Fires automatically after a new allocation is logged.

- Reduces the corresponding resource stock in RESOURCE_INVENTORY.

- Ensures inventory levels stay synchronized with allocations.

--- 

**4. Procedure:** holiday_allocation_check

```sql

CREATE OR REPLACE PROCEDURE holiday_allocation_check(p_date DATE) IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM HOLIDAYS
  WHERE holiday_date = TRUNC(p_date);

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Allocations are not allowed on holidays.');
  END IF;
END;
/

```

**Explanation**:

- Checks if a given date is a holiday.

- If yes, raises an error to block allocations.

- Enforces business rules around holiday scheduling.

---

 ## ✅ Key Takeaways

- **Procedures** automate business rules (alerts, holiday checks).

- **Functions** provide reusable calculations (efficiency metrics).

- **Triggers** enforce integrity (inventory updates).

Together, these PL/SQL programs make AgriOptima active and intelligent, not just passive storage.
