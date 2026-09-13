with orders as (

    select
        order_id,
        customer_id

    from {{ ref('stg_sales_database__order') }}

),

order_items as (

    select
        order_id,
        customer_id,
        order_item_revenue_amount,
        is_completed_order

    from {{ ref('int_sales_database__order_item') }}
    where is_completed_order

),

customers as (

    select
        customer_id,
        customer_first_name,
        customer_last_name

    from {{ ref('stg_sales_database__customer') }}

),

order_counts as (

    select
        customer_id,
        count(distinct order_id) as total_order_count

    from orders
    group by
        customer_id

),

revenue as (

    select
        customer_id,
        sum(order_item_revenue_amount) as total_revenue_amount

    from order_items
    group by
        customer_id

),

final as (

    select
        customers.customer_id,
        customers.customer_first_name,
        customers.customer_last_name,
        coalesce(order_counts.total_order_count, 0) as total_order_count,
        coalesce(revenue.total_revenue_amount, 0) as total_revenue_amount,
        (coalesce(order_counts.total_order_count, 0) >= 2) as is_repeat_customer

    from customers
    left join order_counts
        on customers.customer_id = order_counts.customer_id
    left join revenue
        on customers.customer_id = revenue.customer_id

)

select * from final