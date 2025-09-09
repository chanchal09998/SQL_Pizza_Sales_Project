
# 🍕 Pizza Sales Data Analysis

## 📊 Project Overview
This project performs a comprehensive **data analysis** of a pizza sales dataset using SQL. The main objective is to extract meaningful insights about sales trends, customer behavior, and product performance that can help business decision-making. The dataset includes tables related to pizza types, pizzas, orders, and order details.

The analysis focuses on answering key business questions such as total sales, most popular products, peak order times, revenue distribution, and more.

---

## 🎯 Objectives
- Analyze the total number of orders and total revenue.
- Identify top-performing pizza types by orders and revenue.
- Understand customer ordering patterns by time of day.
- Find the most popular pizza sizes and categories.
- Calculate revenue distribution and cumulative revenue over time.
- Provide actionable insights for business optimization.

---

## ⚡ SQL Queries Performed

```sql
-- Q1: Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

-- Q2: Calculate the total revenue generated from pizza sales.
select sum(quantity*price) from
(
    select od.pizza_id, od.quantity as quantity, p.price as price 
    from order_details od 
    join pizzas p on od.pizza_id = p.pizza_id
) as new_table;

-- Q3: Identify the highest priced pizza.
SELECT pt.name as p_name, pt.category as category, p.price as price
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Q4: Identify the most common pizza size ordered.
select t.size, count(*) 
from
(
    select od.pizza_id, p.size 
    from order_details od 
    join pizzas p on od.pizza_id = p.pizza_id
) as t
group by t.size
order by 2 desc;

-- Q5: List the top 5 most ordered pizza types along with their quantities.
with temp_table as
(
    select pt.name as pizza_name, p.pizza_id, od.quantity as quantity 
    from order_details od 
    join pizzas p on od.pizza_id = p.pizza_id
    join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
) 
select pizza_name, sum(quantity) 
from temp_table
group by pizza_name
order by 2 desc
limit 5;

-- Q6: Find total quantity of each pizza category ordered.
with temp_table as
(
    select pt.category as category, p.pizza_id, od.quantity as quantity 
    from order_details od 
    join pizzas p on od.pizza_id = p.pizza_id
    join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
)
select category, sum(quantity)
from temp_table
group by 1
order by 2 desc;

-- Q7: Distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM order_time) AS hours, COUNT(order_id)
FROM orders
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY 2 desc;

-- Q8: Category-wise distribution of pizzas.
select category, count(name) 
from pizza_types
group by 1;

-- Q9: Average number of pizzas ordered per day.
with temp_table as
(
    select o.order_date, sum(od.quantity) as quantity 
    from order_details od 
    join orders o on od.order_id = o.order_id
    group by 1
)
select round(avg(quantity), 0) as avg_pizza_per_day from temp_table;

-- Q10: Top 3 pizza types based on revenue.
with temp_table as
(
    select pt.name as pizza_names, (p.price * od.quantity) as total_cost 
    from order_details od 
    join pizzas p on od.pizza_id = p.pizza_id
    join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
)
select pizza_names, sum(total_cost) as revenue_per_pizza 
from temp_table
group by 1
order by 2 desc;

-- Q11: Percentage contribution of each pizza type to total revenue.
WITH t2 AS (
    SELECT pt.name AS pizza_names, SUM(p.price * od.quantity) AS revenue_per_pizza
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
)
SELECT 
    pizza_names, 
    round((revenue_per_pizza * 100.0) / SUM(revenue_per_pizza) OVER (), 2) AS revenue_percentage
FROM t2
ORDER BY revenue_per_pizza DESC;

-- Q12: Cumulative revenue generated over time.
with t as
(
    SELECT o.order_date as order_date, sum(od.quantity * p.price) as r_per_day
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    join orders o on o.order_id = od.order_id
    group by 1
    order by 1 
)
select order_date, r_per_day, sum(r_per_day) over(order by order_date) as cumsum from t;

-- Q13: Top 3 most ordered pizza types by revenue for each category.
with t2 as
(
    with t as
    (
        SELECT pt.category as category, pt.name as pizza_name, sum(od.quantity * p.price) as revenue
        FROM order_details od
        JOIN pizzas p ON od.pizza_id = p.pizza_id
        JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        join orders o on o.order_id = od.order_id
        group by 1, 2
        order by 3 desc
    )
    select category, pizza_name, revenue, rank() over(partition by category order by revenue) as rnk
    from t
)
select * from t2 where rnk <= 3;
```
✅ Key Business Insights (Data-Driven Takeaways)

📊 High Revenue Contribution from Few Pizza Types

A small number of pizza types (top 3 by revenue) contribute a large portion of total revenue.

➔ Business Advice: Focus marketing and inventory on these high-performing pizzas to maximize revenue.

⏰ Peak Ordering Hours Identified

Most orders are placed between 12 PM and 3 PM and again between 6 PM and 9 PM.

➔ Business Advice: Staff peak hours adequately and plan promotions during off-peak times to balance order flow.

🍕 Popular Pizza Sizes & Categories

Medium size pizzas are the most commonly ordered.

Certain categories (e.g., Chicken-based pizzas) dominate the order volume.

➔ Business Advice: Ensure availability of popular sizes and categories, and consider discontinuing underperforming products.

💵 High-Value Premium Product Identified

The highest-priced pizza generates significant revenue despite lower order count.

➔ Business Advice: Promote premium offerings for customers seeking luxury or larger options.

📆 Stable Average Daily Sales

On average, X pizzas are sold per day (based on data).

➔ Business Advice: Use this as a benchmark to forecast future sales and manage inventory accordingly.

📉 Revenue Trends Over Time

Cumulative revenue shows steady growth, with noticeable spikes during certain days.

➔ Business Advice: Investigate why specific days have spikes (e.g., holidays, promotions) and replicate successful strategies.

🏆 Top Pizza Categories by Revenue

Certain categories (e.g., Vegetarian, Chicken) consistently generate more revenue.

➔ Business Advice: Focus advertising efforts and menu development around high-revenue categories.

💡 Revenue Contribution by Pizza Type

A few pizza types contribute a disproportionately high percentage of total revenue.

➔ Business Advice: Consider bundling top pizza types with other products or launching targeted deals.
