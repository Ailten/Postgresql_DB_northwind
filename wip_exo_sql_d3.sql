
-- Level 1.

-- 1.
select
    p.product_name,
    c.category_name
from products p
join categories c on (c.category_id = p.category_id);

-- 2.
select
    c.city
from customers c
union
select
    s.city
from suppliers s;

-- level 2.

-- 1.
select
    o.order_id,
    e.first_name
from orders o
join employees e on (o.employee_id = e.employee_id);

-- 2.
select
    c.contact_name as contact_name,
    c.company_name as label
from customers c
union
select
    s.contact_name as contact_name,
    s.company_name as label
from suppliers s;

-- 3.
select
    o.order_id,
    c.company_name,
    s.company_name
from orders o
join customers c on (o.customer_id = c.customer_id)
join shippers s on (o.ship_via = s.shipper_id);

-- level 3.

-- 1.
select
    p.product_name,
    c.category_name,
    s.company_name
from products p
join categories c on (p.category_id = c.category_id)
join suppliers s on (p.supplier_id = s.supplier_id)
order by c.category_name;

-- 2.
select
    (e.first_name || e.last_name) as name
from employees e
union
select
    c.contact_name as name
from customers c
where c.city ilike 'London';

-- 3.
select
    od.order_id,
    p.product_name,
    (p.unit_price * od.quantity) as total_price
from order_details od
join products p on (od.product_id = p.product_id);

-- level 4.

-- 1.
select
    e.employee_id,
    r.region_description
from employees e
join employee_territories et on (et.employee_id = e.employee_id)
join territories t on (t.territory_id = et.territory_id)
join region r on (t.region_id = r.region_id);

-- 2.
select
    *
from (
    select
        _ as report_item,
        _ as total_count
    from
)

select
    'Total Customers' as ReportItem,
    count(c.customer_id) as totalCount
from customers c
union
select
    'Total Suppliers' as ReportItem,
    count(s.supplier_id) as total
from suppliers s
union
select
    'Total Products' as ReportItem,
    count(p.product_id) as total
from products p;


-- PART 2 ------------------------------------------------------------ -->

-- level 1.

-- 1.
select
    *
from products p
where p.unit_price > (
    select avg(p2.unit_price)
    from products p2
);

-- 2.
select
    c.company_name
from customers c
join orders o on (o.customer_id = c.customer_id)
where o.ship_country ilike 'Mexico';

-- 3.
select
    p.unit_price,
    (
        select max(p2.unit_price)
        from products p2
    ) - p.unit_price
from products p;

-- level 2.

-- 1.
select
    p.product_name,
    p.unit_price
from products p
where (
    select
        max(p2.unit_price)
    from products p2
    where p2.category_id = p.category_id
) = p.unit_price;

-- 2.
select
    *
from customers c
where not exists(
    select o.order_id
    from orders o
    where o.customer_id = c.customer_id
);

-- 3.
select
    o.ship_city,
    sum(p.unit_price * od.quantity) as cte
from products p
join order_details od on (od.product_id = p.product_id)
join orders o on (o.order_id = od.order_id)
group by o.ship_city
having sum(p.unit_price * od.quantity) > 50000;

-- with a 'with' function.
with my_func_cte as (
    select
        o.ship_city,
        sum(p.unit_price * od.quantity) as cte
    from products p
    join order_details od on (od.product_id = p.product_id)
    join orders o on (o.order_id = od.order_id)
    group by o.ship_city
)
select * from my_func_cte mfc where mfc.cte > 50000;

-- level 3.

-- 1.
select
    p.product_name,
    p.category_id,
    p.unit_price,
    rank() over(partition by p.category_id)
from products p;

-- 2.
select
    o.order_id,
    o.order_date,
    sum(o.freight) over(partition by date_part('month', o.order_date))
from orders o
where date_part('Y', o.order_date) = 1997
order by o.order_date;

-- 3.
select
    o.order_id,
    o.freight,
    (
        select avg(o2.freight) as avg
        from orders o2
        where o2.ship_country = o.ship_country
    ) as avg
from orders o;

-- level 4.

-- 1.
with recursive my_func_cte2 as (
    select
        e.employee_id,
        e.last_name,
        e.title,
        1 as seniority_level
    from employees e
    where e.reports_to is null
    union
    SELECT
        e2.employee_id,
        e2.last_name,
        e2.title,
        (cte2.seniority_level + 1) as seniority_level
    from my_func_cte2 cte2
    join employees e2 on (cte2.employee_id = e2.reports_to)
)
select
    last_name,
    title,
    seniority_level
from my_func_cte2;

-- 2.
with recursive hierarchy_path_cte as (
    select
        e.employee_id,
        (e.first_name || ' ' || e.last_name) as path
    from employees e
    where e.reports_to is null
    union
    select
        e2.employee_id,
        (hp_cte.path || ' > ' || e2.first_name || ' ' || e2.last_name) as path
    from hierarchy_path_cte hp_cte
    join employees e2 on (e2.reports_to = hp_cte.employee_id)
)
select * from hierarchy_path_cte;

-- 3. (X)
select
    om2.order_month,
    om2.totale_sale_month,
    (om2.totale_sale_month / lag(om2.totale_sale_month) over() -1.0) * 100 as growth_percentage
from (
    select
        om.order_month,
        sum(om.total_sale_order) as totale_sale_month
    from (
        select
            to_char(o.order_date, 'YYYY-MM') as order_month,
            sum(p.unit_price * od.quantity) as total_sale_order
        from orders o
        join order_details od on (od.order_id = o.order_id)
        join products p on (p.product_id = od.product_id)
        group by o.order_id
    ) om
    group by om.order_month
    order by om.order_month
) om2;

-- 3 correction.
with total_sales_per_month as (
    select
        date_part('YEAR', o.order_date) as year,
        date_part('MONTH', o.order_date) as month,
        sum(od.unit_price * od.quantity) as total
    from order_details od
    join orders o on (o.order_id = od.order_id)
    group by year, month
    order by year, month
) select
    *,
    (total / lag(total) over(order by year, month) - 1.0) * 100 as increase
from total_sales_per_month;