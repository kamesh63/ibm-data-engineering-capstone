with branches as (
    select
        branch_id,
        branch_name,
        address,
        region,
        manager_id,
        updated_at,
        region_code
    from {{ ref('stg_branch') }}
),

region_mapping as (
    select
        region_code,
        region_name
    from {{ ref('ref_region_mapping') }}
)

select
    b.branch_id,
    b.branch_name,
    b.address,
    b.region as raw_region,
    b.manager_id,
    b.updated_at,
    b.region_code,
    coalesce(r.region_name, 'Unknown Region') as region_name
from branches b
left join region_mapping r on b.region_code = r.region_code