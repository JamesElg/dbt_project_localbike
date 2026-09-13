-- On-hand stock quantity can never be negative.
-- This test fails if it returns any row.

select
    stock_id,
    stock_quantity
from {{ ref('stg_sales_database__stock') }}
where stock_quantity < 0