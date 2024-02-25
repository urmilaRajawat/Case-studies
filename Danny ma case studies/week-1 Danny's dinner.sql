CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  SELECT * FROM menu;
SELECT s.customer_id, 
SUM(m.price) AS total_amount_spent
FROM sales s JOIN menu m 
ON s.product_id = m.product_id
GROUP BY 1;

-- 2.
SELECT customer_id, COUNT(DISTINCT order_date) AS visited
FROM sales
GROUP BY customer_id;

-- 3 What was the first item from the menu purchased by each customer?

WITH CTE AS (SELECT customer_id, 
product_id, 
row_number() OVER(PARTITION BY customer_id ORDER BY order_date) AS purchase_rnk
FROM sales)

SELECT customer_id, product_name
FROM CTE c JOIN menu m 
ON c.product_id = m.product_id
WHERE purchase_rnk = 1;

-- 3 NOT WORKING 
SELECT s.customer_id, m.product_name
FROM sales s JOIN menu m ON s.product_id = m.product_id
GROUP BY 1 ;

-- 4
-- what is the most purchased item on the menue and how many times was it purchased by the customer
SELECT m.product_name, COUNT(s.product_id) AS order_count
FROM sales s JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY order_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH CTE AS (SELECT customer_id, product_id, COUNT(product_id) as cnt, 
row_number() over(partition by customer_id ORDER BY COUNT(product_id) DESC) as rnk
FROM sales s
GROUP BY customer_id,product_id)

SELECT customer_id, c.product_id, m.product_name, cnt as most_popular
FROM CTE c JOIN menu m ON c.product_id = m.product_id
WHERE rnk = 1;


-- Which item was purchased first by the customer after they became a member?
WITH Ranked_sales AS( SELECT s.customer_id, mn.product_id, mn.product_name, s.order_date, dense_RANK() OVER (partition by customer_id ORDER BY order_date) AS rnk
FROM sales s JOIN members m ON m.customer_id = s.customer_id
JOIN menu mn on mn.product_id = s.product_id
WHERE s.order_date >= m.join_date)

SELECT customer_id, rnk, product_name FROM Ranked_sales
WHERE rnk = 1  ;

-- Which item was purchased just before the customer became a member?
WITH Ranked_sales AS( SELECT s.customer_id, mn.product_id, mn.product_name, s.order_date, dense_RANK() OVER (partition by customer_id ORDER BY order_date) AS rnk
FROM sales s JOIN members m ON m.customer_id = s.customer_id
JOIN menu mn on mn.product_id = s.product_id
WHERE s.order_date < m.join_date)

SELECT customer_id, rnk, product_name FROM Ranked_sales
WHERE rnk = 1  ;

-- What is the total items and amount spent for each member before they became a member?
WITH Ranked_sales AS( SELECT s.customer_id, COUNT(s.product_id) AS total_item, SUM(mn.price) AS amount, mn.product_name, s.order_date, dense_RANK() OVER (partition by customer_id ORDER BY order_date) AS rnk
FROM sales s JOIN members m ON m.customer_id = s.customer_id
JOIN menu mn on mn.product_id = s.product_id
WHERE s.order_date < m.join_date
GROUP BY 1,4,5)

SELECT customer_id, SUM(total_item) as item_count, SUM(amount) as total_amount
FROM Ranked_sales
WHERE rnk = 1 
GROUP BY 1;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id , SUM(points) AS total_points FROM(
SELECT customer_id, (CASE WHEN m.product_id = 1 then price*20 ELSE price*10 END) AS points
FROM sales s 
JOIN menu m ON s.product_id = m.product_id) s
GROUP BY 1;

/*In the first week after a customer joins the program (including their join date) they earn 
2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/
SELECT 
    s.customer_id, 
    SUM(CASE 
            WHEN s.order_date BETWEEN mb.join_date AND DATE_ADD(mb.join_date, INTERVAL 6 DAY) THEN m.price * 20
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END) AS total_points
FROM 
    sales s 
JOIN 
    menu m ON s.product_id = m.product_id
JOIN mytable
    members mb ON mb.customer_id = s.customer_id
WHERE 
    DATE_FORMAT(s.order_date,'%Y-%m-01') = '2021-01-01'
GROUP BY 
    s.customer_id
ORDER BY 
    s.customer_id;

