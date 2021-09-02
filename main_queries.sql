-- Sales and profit by top 10 clients, taking into account refunds and logistics costs.
SELECT c_name, 
	sales, 
	profit - log_costs as profit, 
	ROUND((sales / SUM(sales) OVER()) * 100, 2) as percent_sales,
	ROUND((profit / SUM(profit) OVER()) * 100, 2) as percent_profit FROM 
		(SELECT cl.c_name,
			SUM(op.price * op.count - op.price * op.refund_count) as sales,
			SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)) as profit
		FROM clients as cl
		LEFT JOIN orders as o USING(client_id)
		JOIN orders_products as op USING(order_id)
		GROUP BY cl.c_name) as t1
JOIN
		(SELECT cl.c_name,
			SUM(o.log_costs) as log_costs
		FROM clients as cl
		JOIN orders as o USING(client_id)
		GROUP BY cl.c_name) as t2
USING(c_name)
ORDER BY sales DESC
LIMIT 10;

-- Sales and profit by towns, taking into account refunds and logistics costs.
SELECT town, 
	sales, 
	profit - log_costs as profit, 
	ROUND((sales / SUM(sales) OVER()) * 100, 2) as percent_sales,
	ROUND((profit / SUM(profit) OVER()) * 100, 2) as percent_profit FROM 
		(SELECT cl.town, 
			COALESCE(SUM(op.price * op.count - op.price * op.refund_count), 0) as sales,
			COALESCE(SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)), 0) as profit
		FROM clients as cl
		LEFT JOIN orders USING(client_id)
		LEFT JOIN orders_products as op USING(order_id)
		GROUP BY town) as t1
JOIN
		(SELECT cl.town, 
			COALESCE(SUM(o.log_costs), 0) as log_costs
		FROM clients as cl
		LEFT JOIN orders as o USING(client_id)
		GROUP BY town) as t2
USING(town)
ORDER BY sales DESC;

-- Sales and profit information grouped by category and maker
SELECT pr.category, 
	pr.maker,
	COALESCE(SUM(op.price * op.count - op.price * op.refund_count), 0) as sales,
	COALESCE(SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)), 0) as profit
FROM products as pr
LEFT JOIN orders_products as op USING(p_id)
GROUP BY category, maker
ORDER BY sales DESC;


-- In all of the above queries, we can additionally specify "WHERE" to clarify the time period we are interested!


-- Sales and profit dynamics by months, taking into account returns and logistics costs
SELECT month, 
	sales, 
	profit - log_costs as profit, 
	ROUND((sales / SUM(sales) OVER()) * 100, 2) as percent_sales,
	ROUND((profit / SUM(profit) OVER()) * 100, 2) as percent_profit FROM 
		(SELECT EXTRACT(MONTH FROM o.date) as month,
			SUM(op.price * op.count - op.price * op.refund_count) as sales,
			SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)) as profit
		FROM orders as o
		JOIN orders_products as op USING(order_id)
		WHERE EXTRACT(YEAR FROM o.date) = 2020
		GROUP BY month) as t1
JOIN
		(SELECT EXTRACT(MONTH FROM o.date) as month,
			SUM(o.log_costs) as log_costs
		FROM orders as o
		GROUP BY month) as t2
USING(month);