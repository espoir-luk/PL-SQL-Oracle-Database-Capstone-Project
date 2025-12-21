# Phase VII: Business Rule Implementation

## Business Rule
Employees CANNOT perform INSERT/UPDATE/DELETE operations on:
1. **Weekdays** (Monday to Friday)
2. **Public Holidays** (upcoming month only)

## Implementation Components

### 1. Functions
- **CHECK_RESTRICTION_PERIOD()**: Checks current date against restrictions
- **LOG_AUDIT_TRAIL()**: Logs all DML attempts to AUDIT_LOG table

### 2. Triggers
- **TRG_FARM_RESTRICTION**: Simple trigger on FARM table
- **TRG_INVENTORY_RESTRICTION**: Simple trigger on INVENTORY table  
- **TRG_CROP_TYPE_COMPOUND**: Compound trigger demonstrating bulk processing

### 3. Testing Scenarios
- Weekday operations: BLOCKED with error message
- Weekend operations: ALLOWED
- Holiday operations: BLOCKED
- All attempts logged to AUDIT_LOG

## Database Objects Used
- AUDIT_LOG table (stores all audit records)
- HOLIDAY table (stores public holiday dates)
- AUDIT_LOG_SEQ sequence (generates audit IDs)
