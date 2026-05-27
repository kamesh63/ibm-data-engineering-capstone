{% snapshot sns_account %}

{{
    config(
      target_database='CLIENT360X_DB',
      target_schema='DEVELOPMENT',
      unique_key='acct_id',
      strategy='check',
      check_cols=['balance', 'status', 'close_date'],
    )
}}

select
    acct_id,
    cust_id,
    acct_type,
    balance,
    currency,
    open_date,
    close_date,
    status
from {{ source('dev', 'account') }}

{% endsnapshot %}