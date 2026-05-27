select
    cast(variant_data:cust_id as integer) as cust_id,
    cast(variant_data:first_name as varchar(50)) as first_name,
    cast(variant_data:last_name as varchar(50)) as last_name,
    cast(variant_data:email as varchar(100)) as email,
    cast(variant_data:phone as varchar(20)) as phone,
    cast(variant_data:gender as varchar(20)) as gender,
    cast(variant_data:age as integer) as age,
    cast(variant_data:country as varchar(50)) as country
from {{ source('dev', 'customer_raw') }}