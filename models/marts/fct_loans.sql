with loans as (
    select
        loan_id,
        cust_id,
        loan_type,
        principal,
        interest_rate,
        start_date,
        end_date,
        status
    from {{ ref('stg_loan') }}
)

select
    loan_id,
    cust_id,
    loan_type,
    principal,
    interest_rate,
    start_date,
    end_date,
    status,
    round(principal * (interest_rate / 100), 2) as expected_annual_interest,
    datediff('day', start_date, coalesce(end_date, current_date())) as loan_duration_days
from loans