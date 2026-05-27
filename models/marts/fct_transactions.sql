{{
    config(
        materialized='incremental',
        unique_key='txn_id',
        incremental_strategy='merge'
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

    {% if is_incremental() %}
        where txn_date > (select max(txn_date) from {{ this }})
    {% endif %}
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
    {{ classify_transaction('amount') }} as transaction_value_tier
from transactions