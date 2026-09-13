with renamed as (

    select
        cast(store_id as int64)    as store_id,
        cast(store_name as string) as store_name,
        cast(phone as string)      as store_phone,
        cast(email as string)      as store_email,
        cast(street as string)     as store_street,
        cast(city as string)       as store_city,
        cast(state as string)      as store_state,
        cast(zip_code as string)   as store_zip_code

    from {{ source('sales_database', 'stores') }}

)

select * from renamed