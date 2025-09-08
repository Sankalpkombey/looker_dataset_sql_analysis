----- Customer Segmentation---------------

WITH customer_ltv AS(
 SELECT 
 o.user_id,
 u.first_name || ' ' || u.last_name AS customer_name,
 SUM(oi.sale_price) AS total_ltv
 FROM orders o
 JOIN order_items oi ON o.order_id = oi.order_id
 JOIN users u ON o.user_id = u.id
 GROUP BY o.user_id, u.first_name, u.last_name  
),
customer_segments AS (
 SELECT
   PERCENTILE_CONT(0.25)WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
   PERCENTILE_CONT(0.75)WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
   FROM customer_ltv
),
segment_values AS (
 SELECT
  cl.*,
  CASE
   WHEN cl.total_ltv < cs.ltv_25th_percentile THEN 'Low-Value'
   WHEN cl.total_ltv <= cs.ltv_75th_percentile THEN 'Mid-Value'
   ELSE 'High-Value'
   END AS customer_segment
   FROM customer_ltv cl
   CROSS JOIN customer_segments cs
)
SELECT
  customer_segment,
  SUM(total_ltv) AS total_revenue,
  COUNT(user_id) AS customer_count,
  ROUND(SUM(total_ltv) * 1.0 / COUNT(user_id), 2) AS avg_ltv_per_customer,
  CONCAT(ROUND(100.0 * SUM(total_ltv) / SUM(SUM(total_ltv)) OVER (),1), '%') AS revenue_share_percent
  FROM segment_values
  GROUP BY customer_segment
  ORDER BY
    CASE customer_segment
	 WHEN 'High-Value' THEN 1
	 WHEN 'Mid-Value' THEN 2
	 WHEN 'Low-Value' THEN 3
  END;	 