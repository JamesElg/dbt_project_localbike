with renamed as (

    select
        concat(cast(order_id as string), '-', cast(item_id as string)) as order_item_id,
        cast(order_id as int64)     as order_id,
        cast(item_id as int64)      as item_id,
        cast(product_id as int64)   as product_id,
        cast(quantity as int64)     as order_item_quantity,
        cast(list_price as numeric) as order_item_list_price,
        cast(discount as numeric)   as order_item_discount_rate

    from {{ source('sales_database', 'order_items') }}

)

select * from renamed