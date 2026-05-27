{{
    config(
        materialized='table'
    )
}}

with transactions as (
    select
        txn_id,
        acct_id,
        card_id,
        loan_id,
        cust_id,
        branch_id,
        txn_type,
        amount,
        txn_date,
        txn_channel,
        status,
        remarks
    from {{ ref('stg_transaction') }}
)

select
    txn_id,
    acct_id,
    card_id,
    loan_id,
    cust_id,
    branch_id,
    txn_type,
    amount,
    txn_date,
    txn_channel,
    status,
    remarks,
    -- Execute our custom Jinja macro to tier transactions
    {{ classify_transaction('amount') }} as transaction_value_tier
from transactions