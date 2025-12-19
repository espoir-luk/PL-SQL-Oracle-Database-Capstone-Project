```sql

-- Phase IV: User Setup
-- Run in: THU_27678_ESPOIR_AGRIDPTIMA_DB

-- Create application user
CREATE USER rukundo IDENTIFIED BY Espoir
DEFAULT TABLESPACE agrioptima_data
TEMPORARY TABLESPACE agrioptima_temp;

-- Set quotas
ALTER USER rukundo QUOTA UNLIMITED ON agrioptima_data;
ALTER USER rukundo QUOTA UNLIMITED ON agrioptima_idx;

```
