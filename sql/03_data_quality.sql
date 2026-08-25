-- ============================================================
-- Brazilian E-Commerce BI
-- Data Quality Checks
-- ============================================================


-- ============================================================
-- 1. ROW COUNTS
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation
UNION ALL
SELECT 'daily_website_visitors', COUNT(*) FROM daily_website_visitors
ORDER BY table_name;


-- ============================================================
-- 2. DUPLICATE CHECKS
-- ============================================================

-- Customers: customer_id should be unique
SELECT
    COUNT(*) AS duplicate_customer_ids
FROM (
    SELECT customer_id
    FROM customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) AS duplicates;


-- Orders: order_id should be unique
SELECT
    COUNT(*) AS duplicate_order_ids
FROM (
    SELECT order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS duplicates;


-- Products: product_id should be unique
SELECT
    COUNT(*) AS duplicate_product_ids
FROM (
    SELECT product_id
    FROM products
    GROUP BY product_id
    HAVING COUNT(*) > 1
) AS duplicates;


-- Sellers: seller_id should be unique
SELECT
    COUNT(*) AS duplicate_seller_ids
FROM (
    SELECT seller_id
    FROM sellers
    GROUP BY seller_id
    HAVING COUNT(*) > 1
) AS duplicates;


-- ============================================================
-- 3. MISSING VALUES: ORDERS
-- ============================================================

SELECT
    COUNT(*) FILTER (WHERE order_approved_at IS NULL)
        AS missing_approved_at,

    COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL)
        AS missing_carrier_date,

    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL)
        AS missing_customer_delivery_date
FROM orders;


-- ============================================================
-- 4. MISSING VALUES: PRODUCTS
-- ============================================================

SELECT
    COUNT(*) FILTER (WHERE product_category_name IS NULL)
        AS missing_category,

    COUNT(*) FILTER (WHERE product_name_lenght IS NULL)
        AS missing_name_length,

    COUNT(*) FILTER (WHERE product_description_lenght IS NULL)
        AS missing_description_length,

    COUNT(*) FILTER (WHERE product_photos_qty IS NULL)
        AS missing_photo_count,

    COUNT(*) FILTER (WHERE product_weight_g IS NULL)
        AS missing_weight,

    COUNT(*) FILTER (WHERE product_length_cm IS NULL)
        AS missing_length,

    COUNT(*) FILTER (WHERE product_height_cm IS NULL)
        AS missing_height,

    COUNT(*) FILTER (WHERE product_width_cm IS NULL)
        AS missing_width
FROM products;


-- ============================================================
-- 5. MISSING VALUES: REVIEWS
-- ============================================================

SELECT
    COUNT(*) FILTER (WHERE review_comment_title IS NULL)
        AS missing_review_titles,

    COUNT(*) FILTER (WHERE review_comment_message IS NULL)
        AS missing_review_messages
FROM order_reviews;


-- ============================================================
-- 6. INVALID FINANCIAL VALUES
-- ============================================================

-- Negative prices
SELECT COUNT(*) AS negative_prices
FROM order_items
WHERE price < 0;


-- Negative freight values
SELECT COUNT(*) AS negative_freight_values
FROM order_items
WHERE freight_value < 0;


-- Negative payment values
SELECT COUNT(*) AS negative_payment_values
FROM order_payments
WHERE payment_value < 0;


-- ============================================================
-- 7. INVALID PAYMENT INSTALLMENTS
-- ============================================================

SELECT COUNT(*) AS invalid_installments
FROM order_payments
WHERE payment_installments <= 0;


-- ============================================================
-- 8. INVALID REVIEW SCORES
-- ============================================================

SELECT COUNT(*) AS invalid_review_scores
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;


-- ============================================================
-- 9. INVALID PRODUCT PHYSICAL ATTRIBUTES
-- ============================================================

SELECT COUNT(*) AS invalid_product_weights
FROM products
WHERE product_weight_g <= 0;


SELECT COUNT(*) AS invalid_product_lengths
FROM products
WHERE product_length_cm <= 0;


SELECT COUNT(*) AS invalid_product_heights
FROM products
WHERE product_height_cm <= 0;


SELECT COUNT(*) AS invalid_product_widths
FROM products
WHERE product_width_cm <= 0;


-- ============================================================
-- 10. ORDER TIMESTAMP CONSISTENCY
-- ============================================================

-- Approval before purchase
SELECT COUNT(*) AS approval_before_purchase
FROM orders
WHERE order_approved_at < order_purchase_timestamp;


-- Carrier handoff before purchase
SELECT COUNT(*) AS carrier_before_purchase
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;


-- Carrier handoff before approval
SELECT COUNT(*) AS carrier_before_approval
FROM orders
WHERE order_delivered_carrier_date < order_approved_at;


-- Customer delivery before purchase
SELECT COUNT(*) AS delivery_before_purchase
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


-- Customer delivery before carrier handoff
SELECT COUNT(*) AS delivery_before_carrier
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;


-- ============================================================
-- 11. REVIEW ID DUPLICATES
-- ============================================================

SELECT
    COUNT(*) AS review_ids_with_multiple_orders
FROM (
    SELECT review_id
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(DISTINCT order_id) > 1
) AS duplicate_reviews;


-- ============================================================
-- 12. FOREIGN KEY ORPHAN CHECKS
-- ============================================================

-- Orders without a matching customer
SELECT COUNT(*) AS orders_without_customer
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order items without a matching order
SELECT COUNT(*) AS items_without_order
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order items without a matching product
SELECT COUNT(*) AS items_without_product
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Order items without a matching seller
SELECT COUNT(*) AS items_without_seller
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- Payments without a matching order
SELECT COUNT(*) AS payments_without_order
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Reviews without a matching order
SELECT COUNT(*) AS reviews_without_order
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;