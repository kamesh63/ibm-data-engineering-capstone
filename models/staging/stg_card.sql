select
    card_id,
    cust_id,
    trim(card_type) as card_type,
    card_number,
    issue_date,
    expiry_date,
    trim(status) as status,
    upper(trim(card_validity)) as card_validity
from {{ source('dev', 'card') }}