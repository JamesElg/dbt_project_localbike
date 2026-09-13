with stock as (

    select
        product_id,
        stock_quantity

    from {{ ref('stg_sales_database__stock') }}

),

products as (

    select
        product_id,
        product_name,
        brand_id,
        category_id

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

stock_by_product as (

    select
        product_id,
        sum(stock_quantity) as current_stock_quantity

    from stock
    group by product_id

),

final as (

    select
        products.product_id,
        products.product_name,
        brands.brand_name,
        categories.category_name,
        coalesce(stock_by_product.current_stock_quantity, 0) as current_stock_quantity

    from products
    left join brands
        on products.brand_id = brands.brand_id
    left join categories
        on products.category_id = categories.category_id
    left join stock_by_product
        on products.product_id = stock_by_product.product_id

)

select * from final