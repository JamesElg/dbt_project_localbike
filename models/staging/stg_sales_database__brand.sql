with renamed as (

    select
        cast(brand_id as int64)    as brand_id,
        cast(brand_name as string) as brand_name

    from {{ source('sales_database', 'brands') }}

)

select * from renamed