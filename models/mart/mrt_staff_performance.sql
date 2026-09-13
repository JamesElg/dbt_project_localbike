with order_items as (

    select
        order_id,
        order_date,
        staff_id,
        order_item_revenue_amount,
        is_completed_order

    from {{ ref('int_sales_database__order_item') }}
    where is_completed_order

),

staffs as (

    select
        staff_id,
        staff_first_name,
        staff_last_name,
        store_id

    from {{ ref('stg_sales_database__staff') }}

),

stores as (

    select
        store_id,
        store_name

    from {{ ref('stg_sales_database__store') }}

),

aggregated as (

    select
        date_trunc(order_date, month) as order_month,
        staff_id,
        sum(order_item_revenue_amount) as total_revenue_amount,
        count(distinct order_id) as total_order_count

    from order_items
    group by
        order_month,
        staff_id

),

final as (

    select
        concat(cast(aggregated.staff_id as string), '-', format_date('%Y-%m', aggregated.order_month)) as staff_month_id,
        aggregated.order_month,
        aggregated.staff_id,
        staffs.staff_first_name,
        staffs.staff_last_name,
        staffs.store_id,
        stores.store_name,
        aggregated.total_revenue_amount,
        aggregated.total_order_count

    from aggregated
    left join staffs
        on aggregated.staff_id = staffs.staff_id
    left join stores
        on staffs.store_id = stores.store_id

)

select * from final