-- ============================================================
-- Brazilian E-Commerce BI
-- Load CSV Data into PostgreSQL
-- ============================================================

-- 1. CUSTOMERS
\copy customers FROM 'data/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 2. PRODUCTS
\copy products FROM 'data/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 3. SELLERS
\copy sellers FROM 'data/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 4. ORDERS
\copy orders FROM 'data/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 5. ORDER ITEMS
\copy order_items FROM 'data/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 6. ORDER PAYMENTS
\copy order_payments FROM 'data/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 7. ORDER REVIEWS
\copy order_reviews FROM 'data/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 8. GEOLOCATION
\copy geolocation FROM 'data/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 9. CATEGORY TRANSLATION
\copy category_translation FROM 'data/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, NULL '')

-- 10. DAILY WEBSITE VISITORS
\copy daily_website_visitors FROM 'data/daily-website-visitors.csv' WITH (FORMAT csv, HEADER true, NULL '')