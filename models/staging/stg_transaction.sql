select
    txn_id,
    acct_id,
    card_id,
    loan_id,
    cust_id,
    branch_id,
    trim(txn_type) as txn_type,
    cast(amount as decimal(18,2)) as amount,
    txn_date,
    trim(txn_channel) as txn_channel,
    trim(status) as status,
    trim(remarks) as remarks
from {{ source('dev', 'transaction') }}
where amount > 0