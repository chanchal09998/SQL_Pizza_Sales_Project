-- pizza sales analysis
DROP TABLE IF EXISTS order_details;

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER,
    pizza_id VARCHAR(20),
    quantity INTEGER
);

drop table if exists orders;
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    order_time time
);

drop table if exists pizza_types;
CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150),
    category VARCHAR(100),
    ingredients TEXT
);

drop table if exists pizzas;
CREATE TABLE pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type_id VARCHAR(50),
    size VARCHAR(50),
    price NUMERIC(10, 2),
    FOREIGN KEY (pizza_type_id) REFERENCES pizza_types (pizza_type_id)
);

select * from order_details

select * from orders

select * from pizza_types

select * from pizzas

--Q.1 retrieve the total number of orders placed.
select count(order_id) as total_orders from orders

--Q.2 calculate the total revenue generated from pizza sales.
select sum(quantity*price) from
(
select od.pizza_id,od.quantity as quantity,p.price as price from order_details od join pizzas p on
od.pizza_id=p.pizza_id
) as new_table

--Q.3 identify the highest priced pizza
SELECT pt.name as p_name, pt.category as category, p.price as price
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

--Q.4 identify the most common pizza size ordered.
select t.size,count(*) from
(
select od.pizza_id,p.size from order_details od join pizzas p 
on od.pizza_id=p.pizza_id
)as t
group by t.size
order by 2 desc

--Q.5 list the top 5 most ordered pizza types along with their quantities.
with temp_table as
	(select pt.name as pizza_name,p.pizza_id,od.quantity as quantity from 
	order_details od join pizzas p
	on od.pizza_id=p.pizza_id
	join pizza_types pt
	on p.pizza_type_id=pt.pizza_type_id) 
select pizza_name,sum(quantity) from temp_table
group by pizza_name
order by 2 desc
limit 5

--Q.6 join the necessary tables to find the 
--total quantity of each pizza category ordered.
with temp_table as
(
select pt.category as category,p.pizza_id,od.quantity as quantity from 
	order_details od join pizzas p
	on od.pizza_id=p.pizza_id
	join pizza_types pt
	on p.pizza_type_id=pt.pizza_type_id
	)
	select category ,sum(quantity)from temp_table
	group by 1
	order by 2 desc

--Q.7 determine the  distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM order_time) AS hours, COUNT(order_id)
FROM orders
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY 2 desc;

--Q.8 join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types
group by 1

--Q.9 Group the orders by date and calculate the average number
--of pizzas ordered per day.
with temp_table
as
(
select o.order_date,sum(od.quantity) as quantity from order_details od join orders o
on od.order_id=o.order_id
group by 1
)
select round(avg(quantity),0) avg_pizza_per_day from temp_table

--Q.10 determine the top 3 most pizza types based on revenue.
with temp_table
as(
select pt.name as pizza_names,(p.price*od.quantity) as total_cost from 
	order_details od join pizzas p
	on od.pizza_id=p.pizza_id
	join pizza_types pt
	on p.pizza_type_id=pt.pizza_type_id
)
select  pizza_names,sum(total_cost) as revenue_per_pizza from temp_table
group by 1
order by 2 desc

--Q.11 Calculate the percentage contribution of each pizza type to total revenue.
WITH t2 AS (
    SELECT pt.name AS pizza_names, SUM(p.price * od.quantity) AS revenue_per_pizza
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
)
SELECT 
    pizza_names, 
    round((revenue_per_pizza * 100.0) / SUM(revenue_per_pizza) OVER (),2) AS revenue_percentage
FROM t2
ORDER BY revenue_per_pizza DESC;


--Q.12 analyze the cumulative revenue generated over time.
with t as
(
 SELECT o.order_date as order_date,sum(od.quantity*p.price) as r_per_day
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
	join orders o on o.order_id=od.order_id
    group by 1
	order by 1 
)
select order_date,r_per_day,
sum(r_per_day) over(order by order_date)as cumsum from t

--Q.13 Determine the top 3 most ordered pizza types based on 
--revenue for each pizza category.

with t2 as
(
	with t as
	(
	 SELECT pt.category as category,pt.name as pizza_name,sum(od.quantity*p.price) as revenue
	    FROM order_details od
	    JOIN pizzas p ON od.pizza_id = p.pizza_id
	    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
		join orders o on o.order_id=od.order_id
	    group by 1,2
		order by 3 desc)
	select 
	category,pizza_name,revenue,
	rank() over(partition by category order by revenue) as rnk
	from t
)
select * from t2
where rnk<=3
