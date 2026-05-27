select
    txn_id,
    amount
from {{ ref('stg_transaction') }}
where amount <= 0