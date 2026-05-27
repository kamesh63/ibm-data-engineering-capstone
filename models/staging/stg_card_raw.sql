with raw_source as (
    select
        raw
    from {{ source('dev', 'card_raw') }}
),

flattened_active as (
    select
        value:card_id::integer as card_id,
        value:cust_id::integer as cust_id,
        'Credit' as card_type,
        value:card_number::bigint as card_number,
        value:issue_date::date as issue_date,
        value:expiry_date::date as expiry_date,
        'Active' as status,
        'VALID' as card_validity
    from raw_source,
    lateral flatten(input => raw:Credit.Active)
)

select * from flattened_active