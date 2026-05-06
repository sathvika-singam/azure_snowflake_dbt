# Airbnb Data Pipeline — Azure Blob Storage → Snowflake

A end-to-end data ingestion pipeline that loads Airbnb CSV data from **Azure Blob Storage** into **Snowflake** using a secure storage integration (no SAS tokens).

---

## Architecture

```
Azure Blob Storage (airbnbdata/)
    ├── bookings.csv
    ├── hosts.csv
    └── listings.csv
           │
           │  Storage Integration (OAuth)
           ▼
     Snowflake External Stage
           │
           │  COPY INTO
           ▼
    Snowflake Tables
    ├── HOSTS
    ├── LISTINGS
    └── BOOKINGS
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| Snowflake account | With `ACCOUNTADMIN` role |
| Azure subscription | With permission to assign IAM roles |
| Azure Storage Account | `awstoragedatalakenew` |
| Azure Container | `airbnbdata` with CSV files uploaded |

---

## Setup Guide

### Step 1 — Create tables in Snowflake

Run [`sql/01_create_tables.sql`](sql/01_create_tables.sql)

```sql
USE ROLE ACCOUNTADMIN;
USE DATABASE <your_database>;
USE SCHEMA <your_schema>;
```

Creates three tables: `HOSTS`, `LISTINGS`, `BOOKINGS`

---

### Step 2 — Create CSV file format

Run [`sql/02_file_format.sql`](sql/02_file_format.sql)

---

### Step 3 — Create storage integration

Run [`sql/03_storage_integration.sql`](sql/03_storage_integration.sql)

> **Replace** `<your-azure-tenant-id>` with your actual Tenant ID.  
> Find it in: Azure Portal → Microsoft Entra ID → Overview → Tenant ID

After running, execute:
```sql
DESC INTEGRATION azure_airbnb_int;
```
Copy the values for:
- `AZURE_CONSENT_URL`
- `AZURE_MULTI_TENANT_APP_NAME`

---

### Step 4 — Grant Azure IAM access

1. Open `AZURE_CONSENT_URL` in your browser and click **Accept**
2. Go to Azure Portal → `awstoragedatalakenew` → **Access Control (IAM)**
3. Click **+ Add** → **Add role assignment**
4. Select role: **Storage Blob Data Reader**
5. Search for `AZURE_MULTI_TENANT_APP_NAME` under members
6. Click **Review + assign**

---

### Step 5 — Create external stage

Run [`sql/04_create_stage.sql`](sql/04_create_stage.sql)

Verify with:
```sql
LIST @airbnb_azure_stage;
```
You should see all 3 CSV files listed.

---

### Step 6 — Load data

Run [`sql/05_load_data.sql`](sql/05_load_data.sql)

Load order: `HOSTS` → `LISTINGS` → `BOOKINGS` (respects foreign key relationships)

---

## Verify the Load

```sql
-- Row counts
SELECT 'HOSTS'    AS table_name, COUNT(*) AS row_count FROM HOSTS    UNION ALL
SELECT 'LISTINGS' AS table_name, COUNT(*) AS row_count FROM LISTINGS  UNION ALL
SELECT 'BOOKINGS' AS table_name, COUNT(*) AS row_count FROM BOOKINGS;

-- Preview
SELECT * FROM HOSTS    LIMIT 5;
SELECT * FROM LISTINGS LIMIT 5;
SELECT * FROM BOOKINGS LIMIT 5;

-- Load history
SELECT * FROM INFORMATION_SCHEMA.LOAD_HISTORY
WHERE TABLE_NAME IN ('HOSTS', 'LISTINGS', 'BOOKINGS')
ORDER BY LAST_LOAD_TIME DESC;
```

---

## Table Schema

### HOSTS
| Column | Type | Description |
|---|---|---|
| host_id | NUMBER | Primary key |
| host_name | STRING | Host's full name |
| host_since | DATE | Date host joined |
| is_superhost | BOOLEAN | Superhost status |
| response_rate | NUMBER | Response rate (%) |
| created_at | TIMESTAMP | Record creation time |

### LISTINGS
| Column | Type | Description |
|---|---|---|
| listing_id | NUMBER | Primary key |
| host_id | NUMBER | FK → HOSTS |
| property_type | STRING | e.g. Apartment, House |
| room_type | STRING | e.g. Entire home, Private room |
| city | STRING | City of listing |
| country | STRING | Country of listing |
| accommodates | NUMBER | Max guests |
| bedrooms | NUMBER | Number of bedrooms |
| bathrooms | NUMBER | Number of bathrooms |
| price_per_night | NUMBER | Nightly rate |
| created_at | TIMESTAMP | Record creation time |

### BOOKINGS
| Column | Type | Description |
|---|---|---|
| booking_id | STRING | Primary key |
| listing_id | NUMBER | FK → LISTINGS |
| booking_date | TIMESTAMP | Date of booking |
| nights_booked | NUMBER | Duration |
| booking_amount | NUMBER | Total amount |
| cleaning_fee | NUMBER | Cleaning charge |
| service_fee | NUMBER | Platform fee |
| booking_status | STRING | e.g. confirmed, cancelled |
| created_at | TIMESTAMP | Record creation time |

---

## Troubleshooting

| Error | Fix |
|---|---|
| `Principal not found` in Azure IAM | Complete the consent URL step first (Step 4.1) |
| `LIST @stage` returns empty | Check IAM role assignment and storage integration |
| `COPY INTO` loads 0 rows | Run `VALIDATE()` to check for format errors |
| `Access denied` on stage | Ensure role is assigned at storage account level, not just container |

---

## Tech Stack

- **Azure Blob Storage** — Cloud object storage for raw CSV files
- **Snowflake** — Cloud data warehouse
- **Snowflake Storage Integration** — Secure OAuth-based access (no SAS tokens)
- **COPY INTO** — Snowflake's bulk data loading command
