select
    card_id,
    cust_id,
    trim(card_type) as card_type,
    card_number,
    issue_date,
    expiry_date,
    trim(status) as status,
    case 
        when upper(trim(card_validity)) in ('VALID', 'INVALID') then upper(trim(card_validity))
        else 'INVALID'
    end as card_validity
from {{ source('dev', 'card') }}