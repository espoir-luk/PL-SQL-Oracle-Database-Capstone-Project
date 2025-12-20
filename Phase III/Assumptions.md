# 📖 AgriOptima Project Assumptions

## General Assumptions
- The database schema is implemented under the **RUKUNDO** user in the **thu_27678_Espoir_agriOptima_db** database.
- Each farm section is associated with **one crop type at a time**.
- Sensor readings are timestamped and linked to a single farm section.
- Resource allocations are always logged with both a section and a resource reference.
- Alerts are generated automatically when thresholds are exceeded (moisture, nutrients, pests).
- Holidays are stored as dates to block scheduling of farm activities.

---

## Data Assumptions
- Crop thresholds (moisture, nutrients, pest limits) are defined in **CROP_PROFILES** and remain static unless updated by administrators.
- Farm sections have fixed areas in square meters and statuses (Active, Idle, Maintenance).
- Sensor readings are captured periodically and may vary in frequency depending on crop type.
- Resource inventory levels are tracked in units, with reorder thresholds defined per resource.
- Allocation logs record the exact quantity applied and timestamp of application.
- Alerts contain descriptive messages to guide farm managers in decision-making.
- Holidays are assumed to be non-working days across all farm sections.

---

## Business Process Assumptions
- Farm managers rely on sensor readings and alerts to make resource allocation decisions.
- Resource allocations cannot occur on holidays (business rule enforced in Phase VI with triggers).
- Each allocation log entry represents a completed action, not a planned one.
- Alerts are informational and do not block operations, but they guide corrective measures.
- The ER diagram and schema are aligned with the business process model created in earlier phases.

---

## Technical Assumptions
- Oracle SQL Developer Data Modeler is used to generate and export the ER diagram.
- All tables are created with **primary keys** and appropriate **foreign keys** to enforce referential integrity.
- The schema is migrated from `SYS` to `RUKUNDO` for best practices and visibility in Data Modeler.
- Data types are chosen for simplicity and clarity (NUMBER, VARCHAR2, DATE).
- Bulk data insertion scripts are used to populate tables for testing and validation.

---

## 🔑 Notes
- These assumptions ensure consistency between the **business process model**, **ER diagram**, and **database schema**.
- They provide the rationale behind design decisions and guide future phases (data insertion, PL/SQL programming).
