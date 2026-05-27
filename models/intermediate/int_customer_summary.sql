with accounts as (
    select
        cust_id,
        count(acct_id) as total_accounts_count,
        sum(case when status = 'Active' then 1 else 0 end) as active_accounts_count,
        sum(case when status = 'Active' then balance else 0.00 end) as total_balance
    from {{ ref('stg_account') }}
    group by cust_id
),

cards as (
    select
        cust_id,
        count(card_id) as total_cards_count,
        sum(case when status = 'Active' then 1 else 0 end) as active_cards_count
    from {{ ref('stg_card') }}
    group by cust_id
),

loans as (
    select
        cust_id,
        count(loan_id) as total_loans_count,
        sum(case when status = 'Active' then principal else 0.00 end) as total_loan_principal
    from {{ ref('stg_loan') }}
    group by cust_id
)

select
    c.cust_id,
    coalesce(a.total_accounts_count, 0) as total_accounts_count,
    coalesce(a.active_accounts_count, 0) as active_accounts_count,
    coalesce(a.total_balance, 0.00) as total_balance,
    coalesce(ca.total_cards_count, 0) as total_cards_count,
    coalesce(ca.active_cards_count, 0) as active_cards_count,
    coalesce(l.total_loans_count, 0) as total_loans_count,
    coalesce(l.total_loan_principal, 0.00) as total_loan_principal
from (
    select distinct cust_id from {{ ref('stg_customer_raw') }}
) c
left join accounts a on c.cust_id = a.cust_id
left join cards ca on c.cust_id = ca.cust_id
left join loans l on c.cust_id = l.cust_id