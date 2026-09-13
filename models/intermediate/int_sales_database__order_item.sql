with order_items as (

    select * from {{ ref('stg_sales_database__order_item') }}

),

orders as (

    select * from {{ ref('stg_sales_database__order') }}

),

joined as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.item_id,
        order_items.product_id,
        order_items.order_item_quantity,
        order_items.order_item_list_price,
        order_items.order_item_discount_rate,
        orders.customer_id,
        orders.store_id,
        orders.staff_id,
        orders.order_status,
        orders.order_date,
        orders.required_date,
        orders.shipped_date,
        (orders.order_status = 4) as is_completed_order,
        order_items.order_item_quantity
            * order_items.order_item_list_price
            * (1 - order_items.order_item_discount_rate) as order_item_revenue_amount

    from order_items
    left join orders
        on order_items.order_id = orders.order_id

)

select * from joined