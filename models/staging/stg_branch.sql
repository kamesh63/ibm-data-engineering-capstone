select
    branch_id,
    trim(branch_name) as branch_name,
    trim(address) as address,
    trim(region) as region,
    manager_id,
    updated_at,
    upper(trim(region_code)) as region_code
from {{ source('dev', 'branch') }}