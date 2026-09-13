-- Line-level revenue can never be negative.
select
    order_item_id,
    order_item_revenue_amount
from {{ ref('int_sales_database__order_item') }}
where order_item_revenue_amount < 0