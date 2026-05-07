
-- filter & sorting.

-- 1.
select
    p.product_name,
    p.unit_price,
    p.units_in_stock
from products p
where (
    p.units_in_stock > 0 and
    p.unit_price > 50
)
order by p.unit_price desc;

select 'a' where 'a' ilike 'A';

-- 2.
select
    concat(e.first_name, e.last_name) as full_name
from employees e
where (
    e.city = 'London' or e.city = 'Redmond'
);

-- 3.
select
    *
from customers c
where (
    (c.city = 'London' or c.city = 'Paris') and
    starts_with(c.contact_name, 'S')
);

-- Level 1 (p2).

-- 1.
select
    p.product_name,
    p.unit_price,
    p.units_in_stock
from products p
where (
    p.unit_price between 20 and 50 and
    p.units_in_stock < 10
);

-- 2.
select
    s.company_name,
    s.country
from suppliers s
where (
    s.country in ('UK', 'Sweden', 'Norway')
)
order by s.country;

-- 3.
select
    *
from orders o
where (
    (to_char(o.order_date, 'MM YYYY') = '08 1997') and
    o.freight > 100
);

-- Level 2.

-- 1.
select
    *
from employees e
where (
    e.title_of_courtesy in ('Ms.', 'Mrs.') and
    e.hire_date > date('01 01 1993')
);

select * from customers;

-- 2.
select
    *
from customers c
where (
    --(c.postal_code ~ E'^\\d+$') and
    --cast(c.postal_code as int) < 6

    --left(c.postal_code, 1) between '0' and '5'  -- because 0 and 5 are in numeric order in alphabet.
    c.postal_code ~ '^[0-5]'
);

-- 3.
select
    *
from customers c
where (
    c.contact_title ~~* '%owner%' and  -- contact name (?).
    c.city <> 'Mexico D.F.'
);

-- Level 3.

-- 1.
select
    (p.units_in_stock * unit_price) as total_potential_value
from products p
where (
    (p.units_in_stock * unit_price) > 1000
);

select
    EXTRACT(day from o.required_date - now()) < 5
from orders o;

-- 2.
select
    o.order_id,
    o.order_date,
    o.required_date,
    case
        --when (o.required_date - now()) < 7 then 'express'
        when  o.required_date - o.order_date < 15 then 'express'
        else 'standard'
    end as priority
from orders o;

-- 3.
select
    p.product_name,
    p.unit_price,
    case
        when p.category_id in (1,2) then p.unit_price * 0.9
        else (p.unit_price * 0.95)
    end as sales_prices
from products p;

