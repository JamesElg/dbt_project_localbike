with source as (
    select * from {{ source('sales_database', 'categories') }}
),

renamed as (
    select
        cast(category_id as int64)    as category_id,
        cast(category_name as string) as category_name

    from source
)

select * from renamed