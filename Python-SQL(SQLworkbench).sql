CREATE DATABASE target_dataset;
#-- BASIC PROBLEMS --

#-- 1. Unique cities where customers are located
SELECT DISTINCT customer_city 
FROM customers;

#-- 2. Number of orders placed in 2017
SELECT COUNT(order_id) 
FROM `orders (2)` 
WHERE YEAR(order_purchase_timestamp) = 2017;

#-- 3. Total sales per category
SELECT p.`product category`, SUM(oi.price) AS total_sales
FROM order_items oi
JOIN `products (2)` p ON oi.product_id = p.product_id
GROUP BY p.`product category`;

#-- 4. Percentage of orders paid in installments
SELECT (COUNT(CASE WHEN payment_installments > 1 THEN 1 END) / COUNT(*)) * 100 AS pct_installments
FROM payments;

-- 5. Number of customers from each state
SELECT customer_state, COUNT(customer_id) AS customer_count
FROM customers
GROUP BY customer_state;

-- 1. Number of orders per month in 2018
SELECT MONTH(order_purchase_timestamp) AS month, COUNT(order_id) AS order_count
FROM `orders (2)`
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY month;

-- 2. Average number of products per order by city
SELECT c.customer_city, AVG(order_size.items_count) AS avg_products_per_order
FROM (SELECT order_id, COUNT(product_id) AS items_count FROM order_items GROUP BY order_id) AS order_size
JOIN `orders (2)` o ON order_size.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_city;

-- 3. Percentage of total revenue by product category
SELECT p.`product category`, 
       (SUM(oi.price) / (SELECT SUM(price) FROM order_items) * 100) AS revenue_percentage
FROM order_items oi
JOIN `products (2)` p ON oi.product_id = p.product_id
GROUP BY p.`product category`;

-- 4. Ranking sellers by total revenue
SELECT seller_id, SUM(price) AS total_revenue,
       RANK() OVER (ORDER BY SUM(price) DESC) AS revenue_rank
FROM order_items
GROUP BY seller_id;


-- 1. Cumulative sales per month for each year
SELECT YEAR(o.order_purchase_timestamp) AS year, 
       MONTH(o.order_purchase_timestamp) AS month,
       SUM(p.payment_value) OVER (PARTITION BY YEAR(o.order_purchase_timestamp) ORDER BY MONTH(o.order_purchase_timestamp)) AS cumulative_sales
FROM `orders (2)` o
JOIN payments p ON o.order_id = p.order_id;

-- 2. Top 3 customers who spent the most money in each year
SELECT year, customer_unique_id, total_spent
FROM (
    SELECT YEAR(o.order_purchase_timestamp) AS year, c.customer_unique_id, SUM(p.payment_value) AS total_spent,
           RANK() OVER (PARTITION BY YEAR(o.order_purchase_timestamp) ORDER BY SUM(p.payment_value) DESC) as rnk
    FROM `orders (2)` o
    JOIN payments p ON o.order_id = p.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY year, c.customer_unique_id
) t
WHERE rnk <= 3;