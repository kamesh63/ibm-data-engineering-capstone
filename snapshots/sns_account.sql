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

with deduped_accounts as (
    select
        acct_id,
        cust_id,
        acct_type,
        balance,
        currency,
        open_date,
        close_date,
        status,
        row_number() over (
            partition by acct_id 
            order by coalesce(close_date, '2099-12-31'::date) desc
        ) as rn
    from {{ source('dev', 'account') }}
)

select
    acct_id,
    cust_id,
    acct_type,
    balance,
    currency,
    open_date,
    close_date,
    status
from deduped_accounts
where rn = 1

{% endsnapshot %}