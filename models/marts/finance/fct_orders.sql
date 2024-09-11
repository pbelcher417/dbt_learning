with orders as (
    select * from {{ ref("stg_jaffle_shop__orders") }}
),

payments as (
    select * from {{ ref("stg_stripe__payments") }}
),

payments_per_order as (

    select
    order_id,
    sum(case when status = "success" then amount end) as total_order_payment_amount

    from payments

    group by 1
),

final as (

    select
    orders.order_id,
    orders.customer_id,
    order_date,
    coalesce(payments_per_order.total_order_payment_amount, 0) as total_order_payment_amount

    from orders

    left join payments_per_order on 
    orders.order_id = payments_per_order.order_id
)

select * from final