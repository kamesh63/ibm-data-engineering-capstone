# 📊 IBM Data Engineering Capstone: Client 360 Analytics Platform

An enterprise-grade modern analytics platform engineered using **Snowflake Data Warehouse** and **DBT Cloud** to transform raw transactional, deposit, lending, and semi-structured payloads into an optimized, fully validated, and documented **Client 360 Star Schema**.

---

## 🏗️ System Architecture & Data Flow

Our project implements a hybrid **ELT (Extract, Load, Transform)** operational and analytical pipeline:

```mermaid
graph TD
    subgraph 1. Ingestion & CDC (Snowflake-Native)
        S3["AWS S3 Stage (@dev_s3_stage)"] -->|Auto-Ingest| Pipe["Snowpipe (dev_transaction_pipe)"]
        Pipe -->|Append| RawTxn["Raw TRANSACTION Table"]
        RawAcct["Raw ACCOUNT Table"] -->|CDC Tracking| Stream["account_stream (Stream)"]
        Stream -->|Triggers| Task["process_account_stream_task (Task)"]
        Task -->|DML Audit Log| Audit["ACCOUNT_CHANGE_AUDIT"]
    end

    subgraph 2. Transformations (DBT Core)
        RawTxn -->|stg_transaction| DBT["DBT In-Database Compiler"]
        RawAcct -->|stg_account| DBT
        DBT -->|Materialize| Marts["Star Schema (CLIENT360X_DB.DEVELOPMENT)"]
    end
```

---

## 📂 Project Structure & Model Layout

The DBT project structure follows modular analytics engineering best practices:

*   **`models/staging/`**: Cleanses raw sources, enforces data types, and flattens variant data.
    *   `sources.yml`: Declares raw Snowflake tables and data quality freshness thresholds.
    *   `schema.yml`: Configures staging Generic data quality tests (`unique`, `not_null`, `accepted_values`).
    *   `stg_card_raw.sql`: **Semi-Structured JSON Parsing** utilizing lateral flattens on credit card arrays.
    *   `stg_customer_raw.sql`: **Semi-Structured Parquet Parsing** utilizing case-sensitive key selectors.
*   **`models/intermediate/`**: Handles complex modular aggregations.
    *   `int_customer_summary.sql` (Materialized as **`ephemeral`**): Groups account balances, active cards, and total loans per customer before exposing to the marts layer.
*   **`models/marts/`**: Final business-facing star-schema optimized for BI reports.
    *   `dim_customer.sql`: Client 360 profile compiling client demography with ephemeral account metric totals.
    *   `dim_branch.sql`: Branch details joined with completeness lookups in geographical seeds.
    *   `dim_card.sql`: Consolidated credit/debit catalog executing de-duplication window functions.
    *   `fct_loans.sql`: Loan analytics ledger tracking values and durations.
    *   `fct_transactions.sql` (Materialized **`incrementally`**): High-performance ledger delta-merging transactions.
*   **`seeds/`**: Reference CSV lookups.
    *   `ref_region_mapping.csv`: Static geographic lookup loaded to Snowflake via `dbt seed`.
*   **`macros/`**: Reusable Jinja functions.
    *   `cents_to_dollars.sql`: Standardizes financial decimals.
    *   `classify_transaction.sql`: Implements case-statement business categorization rules.
*   **`snapshots/`**: Slowly Changing Dimensions (SCD Type 2).
    *   `sns_account.sql`: Captures point-in-time account status and balance modifications.
*   **`tests/`**: Custom Singular business-logic rules.
    *   `assert_transaction_amount_is_positive.sql`: Prevents negative log loading.
    *   `assert_loan_end_after_start.sql`: Verifies lending chronology.

---

## ❄️ Snowflake-Native Operations (`snowflake_operational_setup.sql`)

Includes operational pipeline scripts to orchestrate ingestion and CDC directly in Snowflake:
*   **Snowpipe (`dev_transaction_pipe`)**: Serverless continuous ingestion loading files from S3 external stages using secure external Storage Integrations.
*   **Streams (`account_stream`)**: Change Data Capture (CDC) logging table mutations (inserts/updates).
*   **Tasks (`process_account_stream_task`)**: Serverless scheduled task executing DML updates **only when upstream streams contain new data**, saving compute credits.
*   **Stored Procedures (`sp_archive_expired_cards`)**: SQL-based operational routine moving expired records to historical files and updating the active catalog in-place.
*   **Dynamic Tables (`dt_active_checking_balances`)**: Declarative near-real-time staging materializations updating on a target SLA lag.
*   **PCI Column Masking (`card_number_masking_rule`)**: Enterprise governance masking policy redacting raw credit card numbers for standard analyst roles.

---

## 🚀 Execution & Verification Command Guide

Execute the following commands in order in your terminal or DBT console to run and test the complete pipeline:

### 1. Install Library Dependencies
```bash
dbt deps
```
*Installs external DBT libraries (e.g. `dbt_utils`).*

### 2. Verify Database Connection
```bash
dbt debug
```

### 3. Load Seeds Reference Lookup Tables
```bash
dbt seed
```

### 4. Run the Transformations
```bash
dbt run
```
*On the first run, transaction facts are built fully. On subsequent runs, DBT automatically switches to high-performance incremental append-merges.*

### 5. Execute Data Quality Tests
```bash
dbt test
```
*Runs all 48 structural validation tests (uniqueness, not-null constraints, foreign key relationships, and custom business checks).*

### 6. Execute SCD Type 2 Snapshots
```bash
dbt snapshot
```

### 7. Compile & Host the Documentation Catalog
```bash
dbt docs generate
```
*(In DBT Cloud, click on the **Lineage** or **Docs** tabs to browse the auto-compiled visual lineage DAG graph.)*
