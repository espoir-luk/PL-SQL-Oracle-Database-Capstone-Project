# Phase IV: Database Creation

## Overview
This phase involves creating and configuring the Oracle pluggable database for the AgriOptima system, including tablespaces, users, and administrative privileges.

## Database Information
- **Name:** `THU_27678_ESPOIR_AGRIOPTIMA_DB`
- **Type:** Oracle Pluggable Database (PDB)
- **Status:** READ WRITE
- **Creation Date:** December 2025

## Admin User Configuration
| Parameter | Value | Notes |
|-----------|-------|-------|
| Username | `RUKUNDO` | Identifiable as per requirements |
| Password | `rukundo` | Student's first name |
| Role | `DBA` | Super admin privileges |
| Admin Option | `YES` | Can grant DBA to others |

## Tablespace Configuration
| Tablespace | Type | Initial Size | Autoextend | Max Size | Purpose |
|------------|------|--------------|------------|----------|---------|
| AGRIOPTIMA_DATA | Permanent | 500 MB | ON (100M) | 2 GB | Table data storage |
| AGRIOPTIMA_IDX | Permanent | 300 MB | ON (50M) | 1 GB | Index storage |
| AGRIOPTIMA_TEMP | Temporary | 200 MB | ON (50M) | 500 MB | Temporary operations |

## Script Execution Order
1. `01_create_pdb.sql` - Creates the pluggable database
2. `02_create_tablespaces.sql` - Creates custom tablespaces
3. `03_user_setup.sql` - Creates user with quotas
4. `04_grant_privileges.sql` - Grants DBA and other privileges
5. `05_verify_setup.sql` - Verifies complete setup

## Screenshots Documentation
1. **Tablespaces Created** - Shows AGRIOPTIMA_DATA, IDX, TEMP tablespaces
2. **DBA Role Granted** - Shows RUKUNDO has DBA role with ADMIN OPTION
3. **Admin Test** - Shows CREATE USER privilege working
4. 
## Verification Results
- ✅ PDB created and opened successfully
- ✅ Custom tablespaces created with correct sizes
- ✅ User RUKUNDO created with proper tablespace assignments
- ✅ DBA role granted (Super admin requirement satisfied)
- ✅ Admin privileges tested and confirmed
- ✅ All Phase IV requirements met

## Connection String
```bash
sqlplus rukundo/Espoir@THU_27678_ESPOIR_AGRIOPTIMA_DB
