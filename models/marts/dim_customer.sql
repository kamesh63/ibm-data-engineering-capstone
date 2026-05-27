with customer_profiles as (
    select
        cust_id,
        first_name,
        last_name,
        concat(first_name, ' ', last_name) as full_name,
        email,
        phone,
        gender,
        age,
        country
    from {{ ref('stg_customer_raw') }}
),

summary as (
    select
        cust_id,
        total_accounts_count,
        active_accounts_count,
        total_balance,
        total_cards_count,
        active_cards_count,
        total_loans_count,
        total_loan_principal
    from {{ ref('int_customer_summary') }}
)

select
    c.cust_id,
    c.first_name,
    c.last_name,
    c.full_name,
    c.email,
    c.phone,
    c.gender,
    c.age,
    c.country,
    coalesce(s.total_accounts_count, 0) as total_accounts_count,
    coalesce(s.active_accounts_count, 0) as active_accounts_count,
    coalesce(s.total_balance, 0.00) as total_balance,
    coalesce(s.total_cards_count, 0) as total_cards_count,
    coalesce(s.active_cards_count, 0) as active_cards_count,
    coalesce(s.total_loans_count, 0) as total_loans_count,
    coalesce(s.total_loan_principal, 0.00) as total_loan_principal
from customer_profiles c
left join summary s on c.cust_id = s.cust_id