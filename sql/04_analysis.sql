-- ============================================================
-- Brazilian E-Commerce BI
-- Business Analysis
-- ============================================================


-- ============================================================
-- 1. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');


-- ============================================================
-- 2. ORDERS BY STATUS
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- 3. MONTHLY REVENUE TREND
-- ============================================================

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS month,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT o.order_id) AS orders
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 4. MONTHLY ORDER TREND
-- ============================================================

SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::DATE AS month,
    COUNT(*) AS order_count
FROM orders
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 5. REVENUE BY PRODUCT CATEGORY
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY revenue DESC;


-- ============================================================
-- 6. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    oi.product_id,
    ct.product_category_name_english,
    p.product_category_name
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 7. REVENUE BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- ============================================================
-- 8. CUSTOMER PURCHASE FREQUENCY
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM customer_orders
GROUP BY 1
ORDER BY customers DESC;


-- ============================================================
-- 9. TOP CUSTOMER STATES BY AVERAGE ORDER VALUE
-- ============================================================

WITH order_values AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(oi.price) AS order_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        o.order_id,
        c.customer_state
)

SELECT
    customer_state,
    ROUND(AVG(order_value), 2) AS average_order_value,
    COUNT(*) AS orders
FROM order_values
GROUP BY customer_state
ORDER BY average_order_value DESC;


-- ============================================================
-- 10. DELIVERY PERFORMANCE
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NOT NULL
    ) AS delivered_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        ),
        2
    ) AS avg_delivery_days,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_estimated_delivery_date
                )
            ) / 86400
        ),
        2
    ) AS avg_delivery_vs_estimate_days
FROM orders
WHERE order_status = 'delivered';


-- ============================================================
-- 11. ON-TIME VS LATE DELIVERY
-- ============================================================

SELECT
    CASE
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
            THEN 'On Time'
        WHEN order_delivered_customer_date
             > order_estimated_delivery_date
            THEN 'Late'
        ELSE 'Not Delivered'
    END AS delivery_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
GROUP BY 1
ORDER BY order_count DESC;


-- ============================================================
-- 12. REVIEW SCORE DISTRIBUTION
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- ============================================================
-- 13. AVERAGE REVIEW SCORE
-- ============================================================

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score,
    COUNT(*) AS total_reviews
FROM order_reviews;


-- ============================================================
-- 14. REVENUE BY PAYMENT TYPE
-- ============================================================

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;


-- ============================================================
-- 15. WEBSITE TRAFFIC OVER TIME
-- ============================================================

SELECT
    DATE_TRUNC('month', visit_date)::DATE AS month,
    SUM(page_loads) AS page_loads,
    SUM(unique_visits) AS unique_visits,
    SUM(first_time_visits) AS first_time_visits,
    SUM(returning_visits) AS returning_visits
FROM daily_website_visitors
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 16. WEBSITE TRAFFIC SUMMARY
-- ============================================================

SELECT
    SUM(page_loads) AS total_page_loads,
    SUM(unique_visits) AS total_unique_visits,
    SUM(first_time_visits) AS total_first_time_visits,
    SUM(returning_visits) AS total_returning_visits,
    ROUND(
        SUM(returning_visits) * 100.0
        / NULLIF(SUM(unique_visits), 0),
        2
    ) AS returning_visit_rate
FROM daily_website_visitors;