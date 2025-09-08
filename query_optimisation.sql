----- Optimization Techniques ------
SELECT * FROM products
SELECT * FROM order_items
SELECT * FROM orders
--1. Customer Segmentation 

--Before(Unoptimized):
EXPLAIN ANALYZE
SELECT u.id, u.first_name, SUM(sale_price) AS total_ltv
FROM users u, order_items oi
WHERE u.id = oi.user_id
GROUP BY u.id, u.first_name;

--After(Optimized):
EXPLAIN ANALYZE
SELECT u.id, u.first_name, SUM(sale_price) AS total_ltv
FROM users u
JOIN order_items oi ON u.id = oi.user_id
GROUP BY u.id, u.first_name;


--2. Top 10 Cancelled Products by Revenue
EXPLAIN ANALYZE
SELECT p.id, p.name, SUM(sale_price) AS revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Cancelled'
GROUP BY p.id, p.name
ORDER BY revenue DESC
LIMIT 10


-- Create an index for faster filtering

CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_status ON order_items(status);

-- Optimized Query
EXPLAIN ANALYZE
SELECT p.id, p.name, SUM(sale_price) AS revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Cancelled'
GROUP BY p.id, p.name
ORDER BY revenue DESC
LIMIT 10;

--3. Average Order Value (AOV) per Customer
EXPLAIN ANALYZE
SELECT u.id, u.first_name, AVG(oi.sale_price) AS avg_order_value
FROM users u
JOIN order_items oi ON u.id = oi.order_id
GROUP BY u.id, u.first_name;

EXPLAIN ANALYZE
SELECT u.id, u.first_name,
       AVG(oi.sale_price) OVER (PARTITION BY u.id) AS avg_order_value
FROM users u
JOIN order_items oi ON u.id = oi.user_id;
