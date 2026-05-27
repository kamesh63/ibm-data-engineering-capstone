with raw_accounts as (
    select
        acct_id,
        cust_id,
        trim(acct_type) as acct_type,
        {{ cents_to_dollars('balance') }} as balance,
        upper(trim(currency)) as currency,
        open_date,
        close_date,
        trim(status) as status,
        -- Detects duplicates and prioritizes active or latest records
        row_number() over (
            partition by acct_id 
            order by coalesce(close_date, '2099-12-31'::date) desc, open_date desc
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
from raw_accounts
where rn = 1