-- Original Query
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

-- Optimized Query with Window Functions
WITH fulfilled_items AS (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS gross_sales
    FROM order_items
    WHERE status = 'FULFILLED'
    GROUP BY order_id
),
refunds_by_order AS (
    SELECT
        order_id,
        SUM(amount) FILTER (WHERE created_at::date = CURRENT_DATE - 1) OVER (PARTITION BY order_id) AS total_refund
    FROM refunds
)
SELECT
    o.order_id,
    o.customer_id,
    COALESCE(fi.gross_sales, 0) AS gross_sales,
    COALESCE(rbo.total_refund, 0) AS total_refund,
    c.iso_code AS currency
FROM orders o
LEFT JOIN fulfilled_items fi ON fi.order_id = o.order_id
LEFT JOIN refunds_by_order rbo ON rbo.order_id = o.order_id
LEFT JOIN currencies c ON c.currency_id = o.currency_id
WHERE o.created_at::date = CURRENT_DATE - 1
GROUP BY o.order_id, o.customer_id, fi.gross_sales, rbo.total_refund, c.iso_code
ORDER BY gross_sales DESC;

-- EXPLAIN ANALYZE Original Query
EXPLAIN ANALYZE
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

-- EXPLAIN ANALYZE Optimized Query
EXPLAIN ANALYZE
WITH fulfilled_items AS (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS gross_sales
    FROM order_items
    WHERE status = 'FULFILLED'
    GROUP BY order_id
),
refunds_by_order AS (
    SELECT
        order_id,
        SUM(amount) FILTER (WHERE created_at::date = CURRENT_DATE - 1) OVER (PARTITION BY order_id) AS total_refund
    FROM refunds
)
SELECT
    o.order_id,
    o.customer_id,
    COALESCE(fi.gross_sales, 0) AS gross_sales,
    COALESCE(rbo.total_refund, 0) AS total_refund,
    c.iso_code AS currency
FROM orders o
LEFT JOIN fulfilled_items fi ON fi.order_id = o.order_id
LEFT JOIN refunds_by_order rbo ON rbo.order_id = o.order_id
LEFT JOIN currencies c ON c.currency_id = o.currency_id
WHERE o.created_at::date = CURRENT_DATE - 1
GROUP BY o.order_id, o.customer_id, fi.gross_sales, rbo.total_refund, c.iso_code
ORDER BY gross_sales DESC; 
