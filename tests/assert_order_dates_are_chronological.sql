-- An order's required and shipped dates can never precede its order date.
-- This test fails if it returns any row.

select
    order_id,
    order_date,
    required_date,
    shipped_date
from {{ ref('stg_sales_database__order') }}
where required_date < order_date
   or (shipped_date is not null and shipped_date < order_date)