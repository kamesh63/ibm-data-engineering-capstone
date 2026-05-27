with relational_cards as (
    select
        card_id,
        cust_id,
        card_type,
        card_number,
        issue_date,
        expiry_date,
        status,
        card_validity,
        'Structured Database' as record_source
    from {{ ref('stg_card') }}
),

json_cards as (
    select
        card_id,
        cust_id,
        card_type,
        card_number,
        issue_date,
        expiry_date,
        status,
        card_validity,
        'JSON Variant Source' as record_source
    from {{ ref('stg_card_raw') }}
),

unified_cards as (
    select * from relational_cards
    union all
    select * from json_cards
)

select
    card_id,
    cust_id,
    card_type,
    card_number,
    issue_date,
    expiry_date,
    status,
    card_validity,
    record_source,
    case 
        when expiry_date < current_date() then 'Expired'
        else 'Active'
    end as current_validity_status
from unified_cards