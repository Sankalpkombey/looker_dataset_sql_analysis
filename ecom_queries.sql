------ Basic level---------------

--1. List all users
SELECT * FROM users;

--2. Total number of users
SELECT COUNT(*) AS total_users FROM users;

--3. Count total orders
SELECT COUNT(*) AS total_orders FROM orders;

--4. Get total number of products
SELECT COUNT(*) AS total_products FROM products;

--5. Get unique product categories
SELECT DISTINCT category FROM products;

--6. List all distribution centers
SELECT * FROM distribution_centers;

--7. Get top 5 most expensive products
SELECT name, cost FROM products ORDER BY cost DESC LIMIT 5;

--8. Get the cheapest product
SELECT name, cost FROM products ORDER BY cost ASC LIMIT 1;

--9. Get average product price
SELECT AVG(cost) AS avg_price FROM products;

--10. Count orders by status
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status;

--11. Show the count of orders placed by each customer
SELECT user_id, COUNT(*) AS total_orders
FROM orders
GROUP BY user_id
ORDER BY user_id ASC;

--12. Find customers who have placed more than 2 orders
SELECT user_id, COUNT(*) AS order_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 2;

--13. Number of products per category
SELECT product_category, COUNT(*) AS no_of_products
FROM inventory_items
GROUP BY product_category

--14. Total revenue generated
SELECT SUM(sale_price) AS total_revenue
FROM order_items;

--15. Top 5 most frequent browsers
SELECT browser, COUNT(*) AS count
FROM events
GROUP BY browser
ORDER BY count DESC
LIMIT 5;

------ Medium Level----------

--1. Find customers who haven't placed any orders
SELECT * FROM users
WHERE id NOT IN (SELECT DISTINCT user_id FROM orders);

--2. Top 10 selling products by revenue
SELECT product_name, SUM(sale_price) AS revenue
FROM order_items oi
JOIN inventory_items ii ON oi.inventory_item_id = ii.id
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 10;

--3. Monthly sales trend
SELECT DATE_TRUNC('month', created_at) AS month, SUM(sale_price)
FROM order_items
GROUP BY month
ORDER BY month;

--4. Top 10 customers by total spend
SELECT u.id, u.first_name, SUM(oi.sale_price) AS total_spent
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON u.id = oi.order_id
GROUP BY u.id, u.first_name
ORDER BY total_spent DESC
LIMIT 10;

--5. Total revenue generated from each category
SELECT p.category, SUM(oi.sale_price) AS total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

--6. Most used distribution centers
SELECT dc.name, COUNT(*) AS item_count
FROM inventory_items ii
JOIN distribution_centers dc ON ii.product_distribution_center_id = dc.id
GROUP BY dc.name
ORDER BY item_count DESC;

--7. Most frequently ordered products
SELECT p.id, p.name, COUNT(oi.order_id) AS order_count
FROM order_items oi
JOIN products p ON oi.product_id = p.id
GROUP BY p.id, p.name
ORDER BY order_count DESC
LIMIT 10;

--8. Average delivery time per distribution center
SELECT d.name, AVG(DATE_PART('day',sold_at - created_at))::INTEGER AS avg_delivery_days
FROM inventory_items i
JOIN distribution_centers d ON i.product_distribution_center_id = d.id
WHERE sold_at IS NOT NULL
GROUP BY d.name
ORDER BY avg_delivery_days;

--9. Customers who placed orders in every month of the year
SELECT u.id, u.first_name, u.last_name
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE DATE_PART('year', o.created_at) = DATE_PART('year', CURRENT_DATE)
GROUP BY u.id, u.first_name, u.last_name
HAVING COUNT(DISTINCT DATE_PART('month', o.created_at)) = 12;

--10. Top 3 products with highest return rate
SELECT p.name, 
ROUND(SUM(CASE WHEN o.status = 'Returned' THEN 1 ELSE 0 END)::DECIMAL/COUNT(*)*100, 2) AS return_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.name
ORDER BY return_rate DESC
LIMIT 3;

------Advanced Level -------------

--1. Top revenue product in each category
SELECT category, name, total_revenue
FROM (
   SELECT p.category, p.name, SUM(oi.sale_price) AS total_revenue,
   RANK() OVER(PARTITION BY p.category ORDER BY SUM(oi.sale_price) DESC) AS rank
   FROM products p
   JOIN order_items oi ON p.id = oi.product_id
   GROUP BY p.category, p.name
) ranked
WHERE rank = 1;

--2. Find products with declining sales trend
WITH monthly_sales AS (
   SELECT p.id, p.name, DATE_TRUNC('month', o.created_at) AS month,
   SUM(oi.sale_price) AS total_sales
   FROM products p
   JOIN order_items oi ON p.id = oi.product_id
   JOIN orders o ON oi.order_id = o.order_id
   GROUP BY p.id, p.name, month
)
SELECT name
FROM monthly_sales
GROUP BY name
HAVING MAX(total_sales) > MIN(total_sales);

--3. Basket analysis - frequently bought together
SELECT oi1.product_id AS product_a, oi1.product_id AS product_b, COUNT(*) AS frequency
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id
WHERE oi1.order_id < oi2.order_id
GROUP BY product_a, product_b
ORDER BY frequency DESC
LIMIT 10;

--4. Bounce rate estimation: users who visited but didn't buy
WITH visitors AS (
  SELECT DISTINCT user_id FROM events
),
buyers AS (
  SELECT DISTINCT user_id FROM order_items
)
SELECT
  (SELECT COUNT(*) FROM visitors WHERE user_id NOT IN (SELECT user_id FROM buyers))::DECIMAL / COUNT(*) * 100 AS bounce_rate_percent
FROM visitors;

--5. Customer retention by repeat purchases:
SELECT
  CASE
    WHEN order_count = 1 THEN 'One-time Buyer'
	WHEN order_count BETWEEN 2 AND 5 THEN 'Repeat Buyer'
	ELSE 'Loyal Customer'
   END AS customer_type,
  COUNT(*) AS customer_count
FROM (
 SELECT user_id, COUNT(*) AS order_count
 FROM orders
 GROUP BY user_id
) AS sub
GROUP BY customer_type;