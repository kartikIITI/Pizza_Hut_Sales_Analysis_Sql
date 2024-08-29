-- Retrieve the total number of orders placed.
Select count(order_id) as total_orders from orders;
-- 21350

-- Calculate the total revenue generated from pizza sales. 
Select
round(sum(order_details.quantity * pizzas.price),2) as Total_Revenue_Generated
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;
-- 817860.05

-- Identify the highest-priced pizza.
-- M-1--Select max(Price) from pizzahut.pizzas;
-- M-2
Select pizza_types.name, pizzas.price
from 
pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price Desc limit 1;
-- Ans. The Greek Pizza 35.95

-- Identify the most common pizza size ordered.
-- M-1
Select pizza_types.name , pizzas.size
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.size asc limit 1;
-- M-2
Select pizzas.size, count(order_details.order_details_id)
from pizzas join order_details
on pizzas.pizza_id= order_details.pizza_id
group by pizzas.size;

-- List the top 5 most ordered pizza types along with their quantities.
Select pizza_types.name, sum(order_details.quantity) as qunatity
from
   pizza_types 
   join 
   pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join
 order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by quantity DESC 
limit 5;
-- Error in the code

-- Intermediate --
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity) as Quantity 
from pizza_types join pizzas 
on pizzas.pizza_type_id= pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by quantity desc;
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- Determine the distribution of orders by hour of the day.
Select hour(order_time) as hour, count(order_id) from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
Select category, count(name) from pizza_types
group by(category);

-- ## Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) from (
select order_date, sum(order_id) from orders)
group by(order_date);

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name , round(sum(order_details.quantity * pizzas.price),5) as revenue
from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue DESC limit 3;

-- Advanced
-- Calculate the percentage contribution of each pizza type to total revenue.
-- select pizza_types.category , sum(order_details.quantity * pizzas.price) / (select sum(order_details.quantity * pizzas.price) as Total sales)
-- from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id)
-- on order_details.pizza_id = pizzas.pizza_id
-- group by pizza_types.category order by revenue DESC limit 3;
-- Question not done
-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue, rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, sum((order_details.quantity)* pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3;