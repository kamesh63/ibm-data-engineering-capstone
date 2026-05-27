select
    acct_id,
    cust_id,
    trim(acct_type) as acct_type,
    {{ cents_to_dollars('balance') }} as balance,
    upper(trim(currency)) as currency,
    open_date,
    close_date,
    trim(status) as status
from {{ source('dev', 'account') }}