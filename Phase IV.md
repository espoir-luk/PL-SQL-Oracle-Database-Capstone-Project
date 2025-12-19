# Phase IV: Database Creation

## Database Information
- **Name:** THU_27678_ESPOIR_AGRIDPTIMA_DB
- **Type:** Oracle Pluggable Database (PDB)
- **Created:** December 2025

## Admin User Configuration
- **Username:** RUKUNDO
- **Password:** rukundo (first name)
- **Privileges:** DBA role with ADMIN OPTION (Super Admin)

## Tablespace Configuration
| Tablespace | Type | Size | Autoextend | Max Size |
|------------|------|------|------------|----------|
| AGRIOPTIMA_DATA | Permanent | 500MB | YES | 2GB |
| AGRIOPTIMA_IDX | Permanent | 300MB | YES | 1GB |
| AGRIOPTIMA_TEMP | Temporary | 200MB | YES | 500MB |

## Verification
- ✅ PDB created successfully
- ✅ Custom tablespaces created
- ✅ DBA role granted to RUKUNDO
- ✅ Password set to student's first name
- ✅ Admin privileges tested (CREATE USER works)
