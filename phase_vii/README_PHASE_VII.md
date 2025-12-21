# Phase VII: Advanced Programming & Auditing

## Overview
Implementation of triggers, business rules, and comprehensive auditing for the AgriOptima system.

## Files Structure

### 1. Functions
- `check_restriction_period.sql` - Checks if DML operations are allowed
- `log_audit_trail.sql` - Logs all DML attempts to audit table

### 2. Triggers  
- `trg_farm_restriction.sql` - Simple trigger on FARM table
- `trg_inventory_restriction.sql` - Simple trigger on INVENTORY table
- `trg_crop_type_compound.sql` - Compound trigger on CROP_TYPE table

### 3. Testing
- `test_weekday_block.sql` - Tests weekday restriction
- `test_weekend_allow.sql` - Tests weekend allowance  
- `test_holiday_block.sql` - Tests holiday restriction
- `test_all_triggers.sql` - Comprehensive trigger testing

### 4. Audit Queries
- `view_audit_logs.sql` - Views all audit records
- `audit_summary.sql` - Summary report of audit activity

## Business Rule Implementation
The system prevents DML operations on weekdays and public holidays, logging all attempts for compliance.

## Testing Requirements Met
- [x] Trigger blocks INSERT on weekday
- [x] Trigger allows INSERT on weekend  
- [x] Trigger blocks INSERT on holiday
- [x] Audit log captures all attempts
- [x] Error messages are clear
- [x] User info properly recorded
