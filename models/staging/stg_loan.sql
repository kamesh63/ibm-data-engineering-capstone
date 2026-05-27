select
    loan_id,
    cust_id,
    trim(loan_type) as loan_type,
    cast(principal as decimal(12,2)) as principal,
    cast(interest_rate as decimal(6,2)) as interest_rate,
    start_date,
    end_date,
    trim(status) as status
from {{ source('dev', 'loan') }}