with source as (
    select * from {{ source('sales_database', 'brands') }}
),

renamed as (
    select
        cast(brand_id as int64)    as brand_id,
        cast(brand_name as string) as brand_name

    from source
)

select * from renamed