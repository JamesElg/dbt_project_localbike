with order_items as (

    select
        order_date,
        product_id,
        order_item_quantity,
        order_item_list_price,
        order_item_discount_rate,
        order_item_revenue_amount,
        is_completed_order

    from {{ ref('int_sales_database__order_item') }}
    where is_completed_order

),

products as (

    select
        product_id,
        product_name,
        brand_id,
        category_id,
        product_list_price

    from {{ ref('stg_sales_database__product') }}

),

brands as (

    select
        brand_id,
        brand_name

    from {{ ref('stg_sales_database__brand') }}

),

categories as (

    select
        category_id,
        category_name

    from {{ ref('stg_sales_database__category') }}

),

aggregated as (

    select
        date_trunc(order_date, month) as order_month,
        product_id,
        sum(order_item_revenue_amount) as total_revenue_amount,
        safe_divide(
            sum(order_item_quantity * order_item_list_price * order_item_discount_rate),
            sum(order_item_quantity * order_item_list_price)
        ) as average_discount_rate

    from order_items
    group by order_month, product_id

),

final as (

    select
        concat(cast(aggregated.product_id as string), '-', format_date('%Y-%m', aggregated.order_month)) as product_month_id,
        aggregated.order_month,
        aggregated.product_id,
        products.product_name,
        products.brand_id,
        brands.brand_name,
        products.category_id,
        categories.category_name,
        products.product_list_price,
        aggregated.total_revenue_amount,
        aggregated.average_discount_rate

    from aggregated
    left join products
        on aggregated.product_id = products.product_id
    left join brands
        on products.brand_id = brands.brand_id
    left join categories
        on products.category_id = categories.category_id

)

select * from final