
-- level 1.

-- 1.
select
    p.category_id,
    count(*) as quantity
from products p
group by p.category_id;

-- 2.
select
    p.supplier_id,
    avg(p.unit_price) as avg_price
from products p
group by p.supplier_id;

-- 3.
select
    o.employee_id,
    count(*) as quantity_order_by_user
from orders o
group by o.employee_id;

-- level 2.

-- 1.
select
    c.company_name,
    sum(p.unit_price * od.quantity) as total_price
from customers c
join orders o on (o.customer_id = c.customer_id)
join order_details od on (od.order_id = o.order_id)
join products p on (p.product_id = od.product_id)
group by c.customer_id;

-- 2.
select
    c.category_name,
    count(p.product_id) as quantity_of_products
from categories c
join products p on (p.category_id = c.category_id)
group by c.category_id
having count(p.product_id) > 10;

-- 3.
select
    s.company_name,
    avg(o.freight) as avg_freight
from shippers s
join orders o on (o.ship_via = s.shipper_id)
group by s.shipper_id;

-- level 3.

-- 1.
select
    p.product_name,
    c.category_name,
    p.unit_price,
    dense_rank() over(partition by c.category_name order by p.unit_price) as rank
from products p
join categories c on (c.category_id = p.category_id);

-- 2.
select
    od.order_id,
    p.unit_price,
    max(p.unit_price) over (partition by od.order_id) as max_unit_price_per_order
from order_details od
join products p on (p.product_id = od.product_id);

-- 3.  -- TODO: debug.
select
    o.order_id,
    o.freight,
    sum(o.freight) over (order by o.required_date, order_id) as running_total
from orders o
where date_part('Y', o.order_date) = 1997
order by o.required_date;

-- level 4.

-- 1.
select
    c.customer_id,
    max(o.order_date) over(partition by c.customer_id) as last_order_date,
    lag(o.order_date) over(partition by c.customer_id) as previous_order_date
from customers c
join orders o on (o.customer_id = c.customer_id)
order by c.customer_id;

-- 2.
select
    p.product_name,
    c.category_name,
    p.unit_price,
    p.unit_price / (sum(p.unit_price) over(partition by c.category_id)) as purcent_price_category
from products p
join categories c on (p.category_id = c.category_id);

-- 3.
--select
--    distinct p.product_name,
--    sum(od.quantity) over(partition by p.product_id) as quantity_sell
--from products p
--join order_details od on (od.product_id = p.product_id)
--order by sum(od.quantity) over(partition by p.product_id) desc
--limit 3;

select
    c.category_name,
    subquery.product_name,
    subquery.quantity
from (
    select
        p.category_id,
        p.product_name,
        row_number() over(partition by p.category_id order by od.quantity desc) as rank,
        od.quantity
    from products p
    join order_details od on (od.product_id = p.product_id)
) as subquery
join categories c on (c.category_id = subquery.category_id)
where rank < 4;

select
    c.category_name,

from order_details od
join products p on (p.product_id = od.product_id)
join categories c on (c.category_id = p.category_id)



