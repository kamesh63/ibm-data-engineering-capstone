select
    loan_id,
    start_date,
    end_date
from {{ ref('stg_loan') }}
where end_date is not null
  and start_date > end_date