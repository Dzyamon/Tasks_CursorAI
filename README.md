AI In Development: Home Work
1. Web Application: Expense Calculator
Goal:
Develop a web application to calculate the main indicators of monthly expenses based on a user's list of expenses:
Total amount of expenses
Average daily expense
Top 3 largest expenses
Tools:
CursorAI for generating HTML/JS code
CodePen / JSFiddle for testing
Input Format:
The user enters a list of their expenses in the form of a table:
Category
Amount ($)
Groceries
15,000
Rent
40,000
Transportation
5,000
Entertainment
10,000
Communication
2,000
Gym
3,000

Functionality:

The application should provide the user with the following features:
Adding new expenses to the list
Calculating the total amount of expenses (for example, for the data given above: 75,000 $)
Calculating the average daily expense (75,000 / 30 ≈ 2,500 $)
Displaying the top 3 largest expenses (Rent (40,000), Groceries (15,000), Entertainment (10,000))
Expected Result:
After entering data and clicking the "Calculate" button, the following should be displayed on the screen:
Total amount of expenses
Average daily expense
Top 3 expenses

![image](https://github.com/user-attachments/assets/f62cf303-3708-4522-b631-2231762e8003)



2. API Testing: Identifying Defects in Product Data
Task:
Develop automated tests to validate data provided by a public API to detect errors and anomalies.
Tools:
CursorAI for generating test scenarios or ChatGPT.
ReqBin (reqbin.com) or Postman for executing API requests.
API: https://fakestoreapi.com/products (mock store).
Initial Data:
A GET request to https://fakestoreapi.com/products returns an array of objects representing products. The provided JSON data contains defects that need to be identified.
Test Objectives:
Verify server response code (expected 200).
Confirm the presence of the following attributes for each product:
`title` (name) - must not be empty.
`price` (price) - must not be negative.
`rating.rate` -  must not exceed 5.
Generate a list of products containing defects.

RESULTS:
![image](https://github.com/user-attachments/assets/746b98ea-d3a2-4418-91b5-1a348d37f9a8)



4. SQL Queries: Analyzing a Database Online
Goal:
 Write SQL queries to analyze sales data for an online store.
Tools to Use:
SQLite Online


CursorAI/ChatGPT to generate and refine SQL queries


Input Data (Script to Populate the Table):
Run this script in SQLite Online:

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer TEXT,
    amount REAL,
    order_date DATE
);

INSERT INTO orders (customer, amount, order_date) VALUES
('Alice', 5000, '2024-03-01'),
('Bob', 8000, '2024-03-05'),
('Alice', 3000, '2024-03-15'),
('Charlie', 7000, '2024-02-20'),
('Alice', 10000, '2024-02-28'),
('Bob', 4000, '2024-02-10'),
('Charlie', 9000, '2024-03-22'),
('Alice', 2000, '2024-03-30');


Tasks:
Calculate the total sales volume for March 2024.


Find the customer who spent the most overall.


Calculate the average order value for the last three months.


Expected Results:
Total sales for March: 22,000 


Top-spending customer: Alice (18,000 )

![image](https://github.com/user-attachments/assets/afd5d54e-921e-42fc-a93e-d6d74cc39987)


!!! NEW DE !!!
5. 
A nightly job generates the “Yesterday Revenue & Refunds” CSV for Finance.
Since feature growth, the query now takes ~70 s on the warehouse (PostgreSQL 15). Finance needs it below 15 s to meet the SLA.

SQL:
SELECT
    o.order_id,
    o.customer_id,
    SUM(CASE WHEN oi.status = 'FULFILLED' THEN oi.quantity * oi.unit_price ELSE 0 END) AS gross_sales,
    COALESCE(r.total_refund, 0) AS total_refund,
    c.iso_code                                   AS currency
FROM orders o
LEFT JOIN order_items oi
       ON oi.order_id = o.order_id
LEFT JOIN (
    SELECT
        order_id,
        SUM(amount) AS total_refund
    FROM refunds
    WHERE created_at::date = CURRENT_DATE - 1
    GROUP BY order_id
) r ON r.order_id = o.order_id
LEFT JOIN currencies c
       ON c.currency_id = o.currency_id
WHERE o.created_at::date = CURRENT_DATE - 1
GROUP BY
    o.order_id, o.customer_id, r.total_refund, c.iso_code
ORDER BY gross_sales DESC;

Goal
Prompt ChatGPT to spot bottlenecks (two big sequential scans, three hash joins, spill risk).
Ask it for at least two optimisation strategies, e.g. 
Rewrite with window functions to remove the self-aggregating sub-query.
Filter early by moving status='FULFILLED' and the date predicate into CTEs.
Create a partial index on order_items(created_at, status, order_id) WHERE status=‘FULFILLED’.


In Cursor: In the repo open revenue_report.sql, highlight the query, press Ctrl + K →
“Rewrite to use a single window-function to pass over order_items (partition by order_id) and JOIN that result to orders. Eliminate the refunds sub-query by turning it into a window sum on refunds with a FILTER clause. Add EXPLAIN ANALYZE before and after.”



Average order value (total sales / number of orders): 5,750 



