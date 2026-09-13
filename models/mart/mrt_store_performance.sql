with order_items as (

    select * from {{ ref('int_sales_database__order_item') }}
    where is_completed_order

),

stores as (

    select * from {{ ref('stg_sales_database__store') }}

),

aggregated as (

    select
        date_trunc(order_date, month) as order_month,
        store_id,
        sum(order_item_revenue_amount) as total_revenue_amount,
        count(distinct order_id) as total_order_count,
        safe_divide(
            sum(order_item_revenue_amount),
            count(distinct order_id)
        ) as average_order_amount

    from order_items
    group by order_month, store_id

),

final as (

    select
        concat(cast(aggregated.store_id as string), '-', format_date('%Y-%m', aggregated.order_month)) as store_month_id,
        aggregated.order_month,
        aggregated.store_id,
        stores.store_name,
        stores.store_city,
        stores.store_state,
        aggregated.total_revenue_amount,
        aggregated.total_order_count,
        aggregated.average_order_amount

    from aggregated
    left join stores
        on aggregated.store_id = stores.store_id

)

select * from final