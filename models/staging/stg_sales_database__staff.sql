with source as (
    select * from {{ source('sales_database', 'staffs') }}
),

renamed as (
    select
        cast(staff_id as int64)    as staff_id,
        cast(first_name as string) as staff_first_name,
        cast(last_name as string)  as staff_last_name,
        cast(email as string)      as staff_email,
        cast(nullif(phone, 'NULL') as string)      as staff_phone,
        case
            when cast(active as int64) = 1 then true
            else false
        end                        as is_active_staff,
        cast(store_id as int64)    as store_id,
        cast(nullif(manager_id, 'NULL') as int64) as manager_id

    from source
)

select * from renamed