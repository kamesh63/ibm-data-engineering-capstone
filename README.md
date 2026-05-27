# Client 360 Analytics Platform - DBT and Snowflake Ingestion Engine

An enterprise-grade analytics platform designed to ingest, process, validate, and model diverse financial datasets into a unified Customer 360 star-schema inside Snowflake using DBT.

This repository orchestrates continuous data loading, Change Data Capture (CDC), and complex relational transformations across structured and semi-structured datasets, establishing automated quality gates for business intelligence reporting.

---

## 1. System Architecture and Data Flow

This platform implements a hybrid ELT (Extract, Load, Transform) framework. Data ingestion is managed natively by serverless Snowflake components, while analytical transformations are modeled within DBT.

```mermaid
graph TD
    subgraph Ingestion
        S3 -->|Auto-Ingest| Pipe
        Pipe -->|Append| RawTxn
        RawAcct -->|CDC Tracking| Stream
        Stream -->|Triggers| Task
        Task -->|Audit Log| Audit
    end

    subgraph Transformations
        RawTxn -->|stg_transaction| DBT
        RawAcct -->|stg_account| DBT
        DBT -->|Materialize| Marts
    end

    S3[AWS S3 Stage]
    Pipe[Snowpipe]
    RawTxn[Raw TRANSACTION Table]
    RawAcct[Raw ACCOUNT Table]
    Stream[account_stream]
    Task[process_account_stream_task]
    Audit[ACCOUNT_CHANGE_AUDIT Log]
    DBT[DBT Transformation Engine]
    Marts[Star Schema Marts]
end
```
2. Project Layout and Model Topology
The database transformational models are organized into a strict three-tier architecture to enforce modularity and performance:

Staging Layer (models/staging/)
Applies schema enforcement, datatypes casting, and flattens unstructured variants in 1-to-1 mappings with raw Snowflake landing tables. Materialized as lightweight Views.

sources.yml: Declares raw source definitions and ingestion freshness parameters.
schema.yml: Formats column metadata and applies data-quality validations.
stg_branch.sql: Normalizes locations and geographical codes.
stg_card.sql: Sanitizes relational credit and debit logs.
stg_loan.sql: Casts and structures consumer lending matrices.
stg_account.sql: Cleanses checking/savings balances utilizing monetary conversion macros.
stg_transaction.sql: Standardizes transactional entries.
stg_card_raw.sql: Parses semi-structured JSON credit payloads utilizing Snowflake LATERAL FLATTEN paths.
stg_customer_raw.sql: Parses semi-structured Parquet files, resolving case-sensitivity properties on raw variants.
Intermediate Layer (models/intermediate/)
Aggregates and joins staging tables to compute modular pre-marts logic. Materialized as Ephemeral (compiled as inline CTEs to optimize storage).

int_customer_summary.sql: Computes active account metrics, total card limits, and loan principal exposures per customer before exposing to the marts layer.
Marts Layer (models/marts/)
Contains business-facing, highly optimized Star-Schema Dimensions and Facts. Materialized as Tables.

dim_customer.sql: Complies Client 360 profiles, uniting demographics with intermediate deposit metrics.
dim_branch.sql: Branch directory enriched with complete regional descriptions using Seed joins.
dim_card.sql: Blends relational and JSON-parsed card tables into a unique, window-deduplicated card index.
fct_loans.sql: Captures consumer loan principals, expected interest exposures, and durations.
fct_transactions.sql: High-performance transaction ledger materialized incrementally using delta merge strategies.
3. Snowflake Operational Infrastructure (snowflake_operational_setup.sql)
Active operational scripts automate ingestion and monitor transactional updates within Snowflake:

Snowpipe (dev_transaction_pipe): Serverless loading piping raw transaction logs directly from AWS S3 stages utilizing external secure Storage Integrations.
Streams (account_stream): Change Data Capture (CDC) table recording real-time insertions and mutations on accounts.
Tasks (process_account_stream_task): Serverless scheduled task that executes automatically only when upstream CDC streams hold delta records, optimizing compute resources.
Stored Procedures (sp_archive_expired_cards): SQL-based operational transaction that archives expired records to historical directories and purges them from active tables.
Dynamic Tables (dt_active_checking_balances): Declarative near-real-time Materializations capturing active checking metrics on target SLA lags.
4. Data Governance and Quality Gates
Automated Testing
The platform contains 48 automated test configurations running with every integration:

Generic schema constraints: Validates primary key uniqueness (unique), non-null constraints (not_null), and acceptable categorical ranges (accepted_values).
Referential Integrity: Implements foreign key testing (relationships) mapping transaction facts to core dimensions.
Custom Business Rules (Singular Tests):
assert_transaction_amount_is_positive.sql: Rejects anomalous negative values.
assert_loan_end_after_start.sql: Prevents chronological timeline corruption.
Data Security
Column-Level Security (card_number_masking_rule): Snowflake role-based masking policy redacting raw credit card numbers from standard analyst profiles while preserving visibility for authorized administrators (SYSADMIN and ACCOUNTADMIN).
5. Developer Operations and Execution Reference
Execute the following commands sequentially inside your DBT Cloud CLI or terminal to deploy the platform:

1. Install Dependencies
bash


dbt deps
Downloads and installs external project dependencies (e.g. dbt_utils).

2. Verify Snowflake Connectivity
bash


dbt debug
3. Load Static Reference Seeds
bash


dbt seed
Creates reference tables and uploads static CSV geographics into Snowflake.

4. Execute Transformational Pipelines
bash


dbt run
Initial runs execute full history materialization. Subsequent runs automatically delta-merge records on transaction tables.

5. Execute Data Quality Validations
bash


dbt test
6. Execute History-Tracking SCD Snapshots
bash


dbt snapshot
7. Compile Technical Catalog & Documentation
bash


dbt docs generate
(In DBT Cloud, click on the Lineage or Docs tabs to browse the compiled technical data catalog and interactive dependency lineage graph.)
