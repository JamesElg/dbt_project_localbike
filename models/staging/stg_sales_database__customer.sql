with renamed as (

    select
        cast(customer_id as int64) as customer_id,
        cast(first_name as string) as customer_first_name,
        cast(last_name as string)  as customer_last_name,
        cast(nullif(phone, 'NULL') as string)      as customer_phone,
        cast(email as string)      as customer_email,
        cast(street as string)     as customer_street,
        cast(city as string)       as customer_city,
        cast(state as string)      as customer_state,
        cast(zip_code as string)   as customer_zip_code

    from {{ source('sales_database', 'customers') }}

)

select * from renamed