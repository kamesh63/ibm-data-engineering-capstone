select
    cast(variant_data:CUST_ID as integer) as cust_id,
    cast(variant_data:FIRST_NAME as varchar(50)) as first_name,
    cast(variant_data:LAST_NAME as varchar(50)) as last_name,
    cast(variant_data:EMAIL as varchar(100)) as email,
    cast(variant_data:PHONE as varchar(20)) as phone,
    cast(variant_data:GENDER as varchar(20)) as gender,
    cast(variant_data:AGE as integer) as age,
    cast(variant_data:COUNTRY as varchar(50)) as country
from {{ source('dev', 'customer_raw') }}