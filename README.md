Client360X Analytics Platform

Project Overview

End-to-end Customer 360 analytics platform built using Snowflake + dbt + IBM DataStage. It transforms raw financial data into a governed star-schema model for analytics and reporting.

Phase 1: Data Ingestion (Snowflake)

Raw data loaded from AWS S3 into Snowflake using DataStage and COPY INTO.

Tables:

account
branch
card
loan
transaction
card_raw (JSON Variant)
customer_raw (Parquet Variant)
Phase 2: dbt Project Setup
dbt Cloud connected to Snowflake and GitHub repo
Configured:
dbt_project.yml (layer-wise materialization rules)
profiles.yml (Snowflake connection using SYSADMIN role)
packages.yml (dbt_utils dependency)
Phase 3: Staging Layer (Views)

Standardized raw datasets into clean models:

stg_account
stg_branch
stg_card
stg_loan
stg_transaction
stg_card_raw (JSON parsing using LATERAL FLATTEN)
stg_customer_raw (Parquet parsing + schema fixes)
Phase 4: Intermediate Layer (Ephemeral)
int_customer_summary
Aggregates customer-level metrics (accounts, loans, balances, cards)
Compiled as inline CTEs (no physical table)
Phase 5: Marts Layer (Star Schema)
dim_customer → unified Customer 360 profile
dim_branch → branch + region enrichment
dim_card → deduplicated card dimension
fct_loans → loan analytics (interest, duration)
fct_transactions → incremental transaction fact table
Phase 6: Seeds
ref_region_mapping.csv
Maps region codes to full region names
Loaded into Snowflake using dbt seed
Phase 7: Macros
cents_to_dollars → standardizes monetary values
classify_transaction → categorizes transaction value tiers
Phase 8: Snapshots (SCD Type 2)
sns_account
Tracks historical changes in account balance and status
Generates dbt_valid_from and dbt_valid_to
Phase 9: Data Quality Tests (48 Tests)
Schema tests: unique, not_null, relationships, accepted_values
Business rules:
Transaction amount must be positive
Loan end date must be after start date
Phase 10: Snowflake Native Components
Snowpipe → auto ingestion from S3
Streams → CDC tracking on ACCOUNT
Tasks → scheduled automation workflows
Stored Procedure → expired card archival
Materialized View → transaction aggregation
Dynamic Tables → near real-time balances
Masking Policy → secure card number access

Setup, Clone & Run Instructions
1. Clone Repository
git clone https://github.com/<your-org>/ibm-data-engineering-capstone.git
cd ibm-data-engineering-capstone
2. Install Dependencies
dbt deps
3. Verify Snowflake Connection
dbt debug
4. Load Seed Data
dbt seed
5. Run dbt Models
dbt run
6. Run Tests
dbt test
7. Run Snapshots
dbt snapshot
8. Generate Documentation
dbt docs generate
dbt docs serve

Final Outcome
13 dbt models
1 snapshot
1 seed
2 macros
48 tests (all passing)
Fully deployed Snowflake ELT pipeline
