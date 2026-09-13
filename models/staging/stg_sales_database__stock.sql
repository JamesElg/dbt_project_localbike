with renamed as (

    select
        concat(cast(store_id as string), '-', cast(product_id as string)) as stock_id,
        cast(store_id as int64)   as store_id,
        cast(product_id as int64) as product_id,
        cast(quantity as int64)   as stock_quantity

    from {{ source('sales_database', 'stocks') }}

)

select * from renamed