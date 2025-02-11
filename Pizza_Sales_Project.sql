create database project

use project

					--------------------------- PIZZA SALES PROJECT --------------------------------

/* 
1. Retrieve the total number of orders placed. */
	select count(order_id) as Total_orders
	from orders

/*
2. Calculate the total revenue generated from pizza sales. */
	select round(sum(price * quantity),2) as Total_revenue 
	from order_details od join pizzas p 
	on od.pizza_id = p.pizza_id;

/*
3. Identify the highest priced Pizza. */
	select top 1 [name], price 
	from pizzas p join pizza_types pt 
	on p.pizza_type_id = pt.pizza_type_id
	order by price desc;

/*
4. Identify the most common pizza size ordered. */
	select size,sum(quantity) as pizzas_ordered
	from pizzas p join order_details od
	on p.pizza_id = od.pizza_id
	group by size

/*
5. List the top 5 most ordered pizza types along with their quantities. */
	select top 5 pt.[name], sum(quantity) as pizzas_quantity from order_details od 
	join pizzas p
	on od.pizza_id = p.pizza_id
	join pizza_types pt
	on p.pizza_type_id = pt.pizza_type_id
	
	group by pt.[name]
	order by pizzas_quantity desc

/*
6. Join the neccessary table to find the total quantity of each pizza category ordered. */
	select category, sum(quantity) Total_quantity 
	from order_details od 
	join pizzas p
	on od.pizza_id = p.pizza_id
	join pizza_types pt
	on p.pizza_type_id = pt.pizza_type_id
	
	group by category
	order by Total_quantity desc

/*
7. Determine the distribution of orders by hour of the day. */
	SELECT DATEPART(hh, o.[time]) as hrs, COUNT(order_id) as order_count
	FROM orders o
	GROUP BY DATEPART(hh, o.[time])
	order by DATEPART(hh, o.[time])
	
/*
8. Join relevent tables to find the category-wise distribution of pizzas. */
	select category, count(name) as Types_distribution_of_pizzas from pizza_types
	group by category

/*
9. Group the orders by date and calculate the average number of pizzas ordered per day */
	select avg(quant) avg_pizza_ordered_per_day
	from (
	select o.date, sum(od.quantity) as quant 
	from orders o 
	join order_details od on o.order_id = od.order_id 
	group by o.date
	) as daily_orders;

/*
10. Determine the top 3 most ordered pizza types based on revenue. */
	select top 3 pt.category, round(sum(od.quantity * p.price),0) as revenue
	from pizza_types pt join pizzas p
	on pt.pizza_type_id = p.pizza_type_id
	join order_details od
	on p.pizza_id = od.pizza_id
	
	group by pt.category
	order by revenue desc

/*
11. calculate the percentage contribution of each pizza type to total revenue. */

	select pt.category, 
			-- revenue of each category/ whole revenue * 100
			round(((sum(od.quantity * p.price) / 
			(select sum(od.quantity * p.price)
			from pizzas p join order_details od
			on p.pizza_id = od.pizza_id)) * 100),0) as Total_revenue_by_category
	
	from pizza_types pt join pizzas p
	on pt.pizza_type_id = p.pizza_type_id
	join order_details od
	on od.pizza_id = p.pizza_id
	
	group by pt.category
	order by Total_revenue_by_category desc

/*
12. Analyze the cumulative revenue generated over time. */
	
	-- cumulative revenue = Total Revenue earned up to a specific point in time.
	-- 1. Determine the time period (e.g., daily, monthly, quarterly).
	-- 2. Calculate total revenue for each period.
	-- 3. Add each period's revenue to the previous total, carrying forward the cumulative total.
 
	select [date], sum(RevenuePerDay) over (order by [date]) as cum_revenue
	from
	(select [date], sum(p.price * od.quantity) as RevenuePerDay
	from orders o join order_details od
	on o.order_id = od.order_id 
	join pizzas p
	on p.pizza_id = od.pizza_id
	
	group by [date]) as Sales

/*
13. Determine the top 3 most ordered pizza types based on revenue for each pizza category. */
	select b.category,b.name,b.revenue,b.ranking
	from

	(select a.category, a.[name], a.revenue,
	Rank() over(partition by a.category order by a.revenue desc) as ranking
	from

	(select pt.[name], pt.category, sum(od.quantity * p.price) as revenue
	from pizza_types pt join pizzas p
	on pt.pizza_type_id = p.pizza_type_id
	join order_details od
	on p.pizza_id = od.pizza_id
	group by pt.category,pt.[name]) as a) as b

	where ranking <= 3


	-- Alternate Method:
	select b.category, b.name, b.revenue, b.ranking
	from
	
	(select pt.[name], pt.category, sum(od.quantity * p.price) as revenue,
	rank() over(partition by pt.category order by sum(od.quantity * p.price) desc) as ranking
	from pizza_types pt join pizzas p
	on pt.pizza_type_id = p.pizza_type_id
	join order_details od
	on p.pizza_id = od.pizza_id
	group by pt.category,pt.[name]) as b

	where ranking <= 3;

------------------------------------------------------------------------------------------------------------------------------------