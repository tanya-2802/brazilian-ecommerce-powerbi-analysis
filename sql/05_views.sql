-- ============================================================
-- Brazilian E-Commerce BI
-- Power BI Analytical Views
-- ============================================================


-- ============================================================
-- 1. SALES DETAIL VIEW
-- Grain: One row per order item
-- ============================================================

CREATE OR REPLACE VIEW vw_sales_detail AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    c.customer_unique_id,

    o.order_status,
    o.order_purchase_timestamp::DATE AS order_date,

    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    oi.seller_id,

    c.customer_city,
    c.customer_state,

    oi.price AS product_revenue,
    oi.freight_value,

    oi.price + oi.freight_value AS item_total_value

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status NOT IN ('canceled', 'unavailable');


-- ============================================================
-- 2. MONTHLY SALES VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::DATE AS month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_value,

    ROUND(
        SUM(oi.price)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status NOT IN ('canceled', 'unavailable')

GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 3. CATEGORY PERFORMANCE VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS items_sold,

    COUNT(DISTINCT oi.order_id) AS orders,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(SUM(oi.freight_value), 2) AS freight_value,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_value,

    ROUND(
        AVG(oi.price),
        2
    ) AS average_item_price

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status NOT IN ('canceled', 'unavailable')

GROUP BY 1;


-- ============================================================
-- 4. CUSTOMER PERFORMANCE VIEW
-- Grain: One row per unique customer
-- ============================================================

CREATE OR REPLACE VIEW vw_customer_performance AS
SELECT
    c.customer_unique_id,

    MAX(c.customer_state) AS customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    MIN(o.order_purchase_timestamp)::DATE AS first_order_date,

    MAX(o.order_purchase_timestamp)::DATE AS last_order_date,

    ROUND(
        SUM(oi.price),
        2
    ) AS total_revenue,

    ROUND(
        SUM(oi.price)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value,

    CASE
        WHEN COUNT(DISTINCT o.order_id) = 1
            THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status NOT IN ('canceled', 'unavailable')

GROUP BY c.customer_unique_id;


-- ============================================================
-- 5. DELIVERY PERFORMANCE VIEW
-- Grain: One row per order
-- ============================================================

CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    order_id,

    customer_id,

    order_purchase_timestamp::DATE AS order_date,

    order_delivered_customer_date::DATE AS delivery_date,

    order_estimated_delivery_date::DATE AS estimated_delivery_date,

    ROUND(
        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date
                - order_purchase_timestamp
            )
        ) / 86400,
        2
    ) AS delivery_days,

    ROUND(
        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date
                - order_estimated_delivery_date
            )
        ) / 86400,
        2
    ) AS days_vs_estimate,

    CASE
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
            THEN 'On Time'

        WHEN order_delivered_customer_date
             > order_estimated_delivery_date
            THEN 'Late'

        ELSE 'Not Delivered'
    END AS delivery_status

FROM orders

WHERE order_status = 'delivered';


-- ============================================================
-- 6. CUSTOMER SATISFACTION VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_customer_satisfaction AS
SELECT
    o.order_id,

    o.customer_id,

    r.review_score,

    CASE
        WHEN r.review_score >= 4 THEN 'Positive'
        WHEN r.review_score = 3 THEN 'Neutral'
        WHEN r.review_score <= 2 THEN 'Negative'
        ELSE 'Unknown'
    END AS review_sentiment,

    r.review_creation_date::DATE AS review_date

FROM order_reviews r

JOIN orders o
    ON r.order_id = o.order_id;


-- ============================================================
-- 7. PAYMENT PERFORMANCE VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_payment_performance AS
SELECT
    payment_type,

    COUNT(*) AS payment_records,

    COUNT(DISTINCT order_id) AS orders,

    ROUND(
        SUM(payment_value),
        2
    ) AS payment_value,

    ROUND(
        AVG(payment_value),
        2
    ) AS average_payment,

    ROUND(
        AVG(payment_installments),
        2
    ) AS average_installments

FROM order_payments

GROUP BY payment_type;


-- ============================================================
-- 8. WEBSITE TRAFFIC VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_website_traffic AS
SELECT
    visit_date,

    day,

    day_of_week,

    page_loads,

    unique_visits,

    first_time_visits,

    returning_visits,

    ROUND(
        returning_visits * 100.0
        / NULLIF(unique_visits, 0),
        2
    ) AS returning_visit_rate

FROM daily_website_visitors;