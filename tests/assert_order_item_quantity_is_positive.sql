-- A sold quantity can never be zero or negative.
-- This test fails if it returns any row.

select
    order_item_id,
    order_item_quantity
from {{ ref('stg_sales_database__order_item') }}
where order_item_quantity <= 0