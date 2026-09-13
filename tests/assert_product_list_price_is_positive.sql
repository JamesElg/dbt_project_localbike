-- A product's catalog list price must always be strictly positive.
-- This test fails if it returns any row.

select
    product_id,
    product_list_price
from {{ ref('stg_sales_database__product') }}
where product_list_price <= 0