use retailmart_db
-- LEVEL 1
-- List all products in the "Electronics" category, ordered by price descending

SELECT p.product_name, p.unit_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE c.category_name = 'Electronics'
ORDER BY p.unit_price desc;

-- Find all customers located in "California" (state = 'CA')

select distinct customer_id, first_name, last_name, state
from customers 
where state = 'CA';

-- List all orders with status 'Cancelled'

select order_id, customer_id, status
from orders 
where status= 'Cancelled'

-- Find the 10 most expensive products

select product_name, unit_price
from products 
order by unit_price desc
limit 10;

-- LEVEL 2
-- How many products exist in each category?

select  c.category_name, count(p.product_id) as product
from products p
join categories c on p.category_id = c.category_id
group by category_name

-- What is the total number of orders placed by each customer? (top 10 customers)

select c.customer_id,  c.first_name, c.last_name, count(o.order_id) as total_orders
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id
order by total_orders desc
limit 10;

--  What is the average order value per employee (join orders → order_items)?

select o.employee_id, e.first_name, e.last_name, avg(i.order_item_id) as average_orders
from orders o
join order_items i on o.order_id = i.order_id
left join employees e on e.employee_id = o.employee_id
group by o.employee_id 
order by average_orders desc;

-- Which product category has generated the most total revenue?

select c.category_id, c.category_name, sum(p.unit_price * i.quantity) as total_revenue
from categories c
join products p on c.category_id = p.category_id
join order_items i on p.product_id = i.product_id
group by c.category_name, c.category_id
order by total_revenue desc; 

-- Count orders by status (Delivered, Shipped, Processing, Cancelled, Returned)

select status, count(order_id) as No_of_orders
from orders
group by status
order by No_of_orders;

-- LEVEL 3
-- List each order with the customer's full name and order date

select o.order_id, c.first_name, c.last_name, o.order_date
from customers c
join orders o on c.customer_id = o.customer_id
order by o.order_id;

-- List each order item with the product name and category name

select oi.order_item_id as order_item, p.product_name, c.category_name
from categories c
join products p on c.category_id = p.category_id
join order_items oi on oi.product_id = p.product_id
order by order_item;

-- Find the total revenue (quantity × unit_price × (1-discount)) per order

select order_id, sum(quantity * unit_price * (1-discount)) as total_revenue
from order_items
group by order_id
order by total_revenue desc;

-- Find which employee has processed the most orders

select o.employee_id, e.first_name, e.last_name, e.role, count(o.order_id) as No_of_orders
from orders o
join employees e on o.employee_id = e.employee_id
group by  o.employee_id
order by No_of_orders  desc;

-- LEVEL 4
-- Find customers who have placed more than 10 orders
 
 select  o.customer_id, c.first_name, c.last_name, count(o.order_id) as No_of_orders
 from orders o
 join customers c on o.customer_id = c.customer_id
 group by c.first_name, c.last_name, o.customer_id
 having No_of_orders > 10
 order by No_of_orders desc;

-- Find products that have never been ordered

select p.product_id, p.product_name,  count(oi.order_item_id) as items_ordered
from products p
left join order_items oi on p.product_id = oi.product_id
group by p.product_id, p.product_name
having items_ordered = 0
order by items_ordered asc; 

-- Find the category with the highest average product price

select c.category_name,  avg(p.unit_price) as average_product_price
from categories c
join products p on c.category_id = p.category_id
group by c.category_name
order by average_product_price desc
limit 1;

-- Find customers whose total spend is above the overall average customer spend

select c.customer_id, c.first_name, c.last_name, sum(oi.quantity * oi.unit_price) as total_spend
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by c.customer_id, c.first_name, c.last_name
having total_spend > (
select avg(customer_spend)
from(
select c2.customer_id, sum(oi2.quantity * oi2.unit_price) as customer_spend
from customers c2
join orders o2 on c2.customer_id = o2.customer_id
join order_items oi2 on o2.order_id = oi2.order_id
GROUP BY c2.customer_id
    ) AS customer_totals
)
order by total_spend desc;
