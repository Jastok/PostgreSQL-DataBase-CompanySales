-- Sales and profit by top 10 clients, taking into account refunds and logistics costs.
WITH 
t1 as 
(SELECT cl.c_name,
	SUM(op.price * op.count - op.price * op.refund_count) as sales,
	SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)) as profit
FROM clients as cl
LEFT JOIN orders as o USING(client_id)
JOIN orders_products as op USING(order_id)
GROUP BY cl.c_name),
		
t2 as 
(SELECT cl.c_name,
	SUM(o.log_costs) as log_costs
FROM clients as cl
JOIN orders as o USING(client_id)
GROUP BY cl.c_name)
		
SELECT ROW_NUMBER() OVER(ORDER BY sales DESC) as rank,
	c_name, 
	sales, 
	profit - log_costs as net_profit, 
	ROUND((sales / SUM(sales) OVER()) * 100, 2) as percent_sales
FROM t1
JOIN t2
USING(c_name)
ORDER BY sales DESC
WHERE rank <= 10;

-- Sales and profit by towns, taking into account refunds and logistics costs.
WITH 
t1 as 
(SELECT cl.town, 
	COALESCE(SUM(op.price * op.count - op.price * op.refund_count), 0) as sales,
	COALESCE(SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)), 0) as profit
FROM clients as cl
LEFT JOIN orders USING(client_id)
LEFT JOIN orders_products as op USING(order_id)
GROUP BY town),

t2 as 
(SELECT cl.town, 
	COALESCE(SUM(o.log_costs), 0) as log_costs
FROM clients as cl
LEFT JOIN orders as o USING(client_id)
GROUP BY town)

SELECT town, 
	sales, 
	profit - log_costs as net_profit, 
	ROUND((sales / SUM(sales) OVER()) * 100, 2) as percent_sales
FROM t1
JOIN t2
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


-- In all of the above queries we can additionally specify "WHERE" to clarify the time period we are interested!


-- Sales and profit dynamics by months, taking into account returns and logistics costs
WITH 
t1 as 
(SELECT EXTRACT(MONTH FROM o.date) as month,
	SUM(op.price * op.count - op.price * op.refund_count) as sales,
	SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)) as profit
FROM orders as o
JOIN orders_products as op USING(order_id)
WHERE EXTRACT(YEAR FROM o.date) = 2020
GROUP BY month),

t2 as 
(SELECT EXTRACT(MONTH FROM o.date) as month,
	SUM(o.log_costs) as log_costs
FROM orders as o
WHERE EXTRACT(YEAR FROM o.date) = 2020
GROUP BY month)

SELECT month, 
	sales, 
	profit - log_costs as net_profit, 
	ROUND((sales / SUM(sales) OVER()) * 100, 2) as percent_sales 
FROM t1
JOIN t2
USING(month)

-- Information on the most popular products for the client (all information about the products purchased by the client)
SELECT pr.p_name, 
	SUM(op.price * op.count - op.price * op.refund_count) as sales,
	SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)) as profit
FROM products as pr
JOIN orders_products as op USING(p_id)
JOIN orders USING(order_id)
JOIN clients as cl USING(client_id)
WHERE cl.client_id = 1
GROUP BY p_name
ORDER BY sales DESC

-- All order information
SELECT p_name, 
	count, 
	sales, 
	profit, 
	total_profit, 
	total_profit - log_costs as net_profit FROM
		(SELECT pr.p_id,
 			pr.p_name, 
 			SUM(op.count),
			SUM(op.price * op.count - op.price * op.refund_count) as sales,
			SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)) as profit,
			SUM(SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count))) OVER() as total_profit
		FROM products as pr
		JOIN orders_products as op USING(p_id)
		JOIN orders as o USING(order_id)
		WHERE o.order_id = 1
		GROUP BY p_id
		ORDER BY sales DESC) as t1
		JOIN orders_products as op USING(p_id)
		JOIN orders as o USING(order_id)
		WHERE o.order_id = 1

-- Monthly sales report
WITH
t1 as 
(SELECT o.order_id, 
	SUM(op.price * op.count - op.price * op.refund_count) as sales,
	SUM((op.price * op.count - op.price * op.refund_count) - (op.p_costs * op.count - op.p_costs * op.refund_count)) as profit
FROM clients as cl
JOIN orders as o USING(client_id)
JOIN orders_products as op USING(order_id)
WHERE to_char(o.date, 'YYYY-MM') = '2021-08'
GROUP BY order_id),

t2 as 
(SELECT order_id, 
	SUM(log_costs) as log_costs
FROM orders
WHERE to_char(date, 'YYYY-MM') = '2021-08'
GROUP BY order_id),

t3 as 
(SELECT order_id, 
	sales, 
	profit - log_costs as net_profit 
FROM t1
JOIN t2
USING(order_id))

SELECT date,
	doc,
	c_name, 
	sales, 
	net_profit,
	ROUND((net_profit / SUM(net_profit) OVER()) * 100, 2) as percent_profit 
FROM t3
JOIN orders USING(order_id)
JOIN clients USING(client_id)
ORDER BY date