# Brazilian E-Commerce BI Project

## Dataset Overview

This project uses the **Brazilian E-Commerce Public Dataset by Olist**.

The raw source consists of nine in-scope datasets:

| Dataset | Rows | Columns | Grain |
|---|---:|---:|---|
| Customers | 99,441 | 5 | One customer record |
| Orders | 99,441 | 8 | One order |
| Order Items | 112,650 | 7 | One item within an order |
| Order Payments | 103,886 | 5 | One payment record associated with an order |
| Order Reviews | 99,224 | 7 | One review record associated with an order |
| Products | 32,951 | 9 | One product |
| Sellers | 3,095 | 4 | One seller |
| Geolocation | 1,000,163 | 5 | One geolocation record |
| Category Translation | 71 | 2 | One category translation |

## Dataset Findings

### Customers

- `customer_id` is unique across all 99,441 records.
- `customer_unique_id` contains 96,096 distinct values.
- Multiple `customer_id` records can therefore belong to the same `customer_unique_id`.
- Use `customer_unique_id` when the analysis requires unique-customer identification.

### Orders

- `order_id` is unique across all 99,441 records.
- The table grain is one row per order.
- `order_id` is the candidate primary key.

### Order Items

- The table contains 112,650 item records across 98,666 distinct orders.
- `order_item_id` is not globally unique.
- `order_id` + `order_item_id` is the candidate composite key.
- An order can contain multiple item records.

### Order Payments

- The table contains 103,886 payment records across 99,440 distinct orders.
- An order can have multiple payment records.
- `payment_sequential` is not globally unique.
- `order_id` + `payment_sequential` is the candidate composite key.

### Order Reviews

- The table contains 99,224 review records.
- `review_id` is not unique in the source data.
- 789 review IDs are associated with multiple orders.
- No exact duplicate rows were identified across all review columns.
- Review records should not be deduplicated solely using `review_id`.
- Review metrics should be aggregated at the appropriate analytical grain before being joined to order- or item-level data.

### Products

- `product_id` is unique across all 32,951 product records.
- The table grain is one row per product.
- `product_id` is the candidate primary key.

### Sellers

- `seller_id` is unique across all 3,095 seller records.
- The table grain is one row per seller.
- `seller_id` is the candidate primary key.

### Geolocation

- The dataset contains 1,000,163 records.
- There are 19,015 distinct ZIP-code prefixes.
- Multiple geolocation records can therefore exist for the same ZIP-code prefix.
- Geolocation should not be treated as a one-to-one ZIP-prefix lookup without further validation.

### Category Translation

- The dataset contains 71 category translation records.
- `product_category_name` is unique.
- The table functions as a category lookup/reference table.

## Missing-Value Overview

The profiling identified missing values across several datasets.

### Orders

- `order_delivered_customer_date`: missing for 2.98% of orders.
- `order_delivered_carrier_date`: missing for 1.79% of orders.
- `order_approved_at`: missing for 0.16% of orders.

Most missing timestamps are consistent with the order lifecycle and should be interpreted alongside `order_status`.

### Reviews

- `review_comment_title`: missing for 88.34% of records.
- `review_comment_message`: missing for 58.70% of records.

These fields represent optional customer-provided content.

### Products

The following fields are each missing for 610 records:

- `product_category_name`
- `product_name_lenght`
- `product_description_lenght`
- `product_photos_qty`

Product weight and dimension fields each contain 2 missing values.

Detailed data-quality issues, impacts, and treatment decisions are documented separately in the [Data Quality Report](data_quality.md).

## Scope Note

The local data directory also contains `daily-website-visitors.csv`.

This file is outside the scope of the current Olist e-commerce analysis and is not included in the analytical pipeline.

## Profiling Status

The dataset structure, grain, candidate keys, and major missing-value patterns have been profiled.

Further validation is handled through the project's SQL data-quality workflow, including:

- Data-type validation
- Date validation
- Numeric validation
- Referential integrity
- Cross-table reconciliation
