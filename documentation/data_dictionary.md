# Brazilian E-Commerce BI Project

## Dataset Overview

This project uses the Brazilian E-Commerce Public Dataset by Olist.

The raw source consists of nine in-scope datasets:

| Dataset              |      Rows | Columns | Grain                                       |
| -------------------- | --------: | ------: | ------------------------------------------- |
| Customers            |    99,441 |       5 | One customer record                         |
| Orders               |    99,441 |       8 | One order                                   |
| Order Items          |   112,650 |       7 | One item within an order                    |
| Order Payments       |   103,886 |       5 | One payment record associated with an order |
| Order Reviews        |    99,224 |       7 | One review record associated with an order  |
| Products             |    32,951 |       9 | One product                                 |
| Sellers              |     3,095 |       4 | One seller                                  |
| Geolocation          | 1,000,163 |       5 | One geolocation record                      |
| Category Translation |        71 |       2 | One category translation                    |

## Key Findings

### Customers

* `customer_id` is unique across the 99,441 records.
* `customer_unique_id` contains 96,096 distinct values.
* Multiple `customer_id` records can therefore belong to the same `customer_unique_id`.
* Unique-customer metrics should use `customer_unique_id` where the analytical objective is to identify individual customers across records.

### Orders

* `order_id` is unique across the 99,441 records.
* The table grain is one row per order.
* `order_id` is the candidate primary key.

### Missing-Value Findings

- `order_delivered_customer_date` is missing for 2.98% of orders.
- `order_delivered_carrier_date` is missing for 1.79% of orders.
- `order_approved_at` is missing for 0.16% of orders.
- These fields require validation against `order_status` before determining whether the missing values represent expected process states or data-quality issues.

### Delivered Orders Missing Customer Delivery Timestamp

Eight orders have `order_status = 'delivered'` but no `order_delivered_customer_date`.

- 7 of these orders have a populated `order_delivered_carrier_date`.
- 1 order has neither a carrier delivery timestamp nor a customer delivery timestamp.
- These records are retained as source data.
- Delivery-duration and delivery-timeliness metrics will require a valid customer delivery timestamp and will not impute missing dates.

### Order Lifecycle Validation

Missing timestamps were compared against `order_status`.

Most missing timestamps are consistent with the order lifecycle. For example, orders that are canceled, processing, invoiced, shipped, or unavailable may not have reached subsequent delivery stages.

The following exceptions were identified and require further investigation:

- 14 `delivered` orders have a missing `order_approved_at`.
- 2 `delivered` orders have a missing `order_delivered_carrier_date`.
- 8 `delivered` orders have a missing `order_delivered_customer_date`.

These records will not be removed during profiling. They will be retained and evaluated during subsequent validation and KPI development.

### Order Items

* The table contains 112,650 item records across 98,666 distinct orders.
* `order_item_id` is not globally unique and should not be treated as a standalone primary key.
* The combination of `order_id` and `order_item_id` is the candidate composite key.
* An order can contain multiple item records.

### Order Payments

* The table contains 103,886 payment records across 99,440 distinct orders.
* An order can therefore have multiple payment records.
* `payment_sequential` is not globally unique.
* The combination of `order_id` and `payment_sequential` is the candidate composite key.

### Order Reviews

* The table contains 99,224 review records.
* `review_id` is not unique in the source data.
* 789 review IDs are associated with multiple orders.
* No exact duplicate rows were identified across all review columns.
* Review records should therefore not be deduplicated solely based on `review_id`.
* Review metrics must be aggregated at an appropriate analytical grain before being joined to order-level or item-level data.

### Missing-Value Findings

- `review_comment_title` is missing for 88.34% of records.
- `review_comment_message` is missing for 58.70% of records.
- These fields are treated as optional customer-provided content rather than automatically classifying the records as invalid.

### Products

* `product_id` is unique across all 32,951 product records.
* The table grain is one row per product.
* `product_id` is the candidate primary key.

### Missing-Value Findings

- `product_category_name`, `product_name_lenght`, `product_description_lenght`, and `product_photos_qty` are each missing for 610 records.
- The shared missing-record count suggests these fields may be missing for the same products and requires further validation.
- Product weight and dimensions each contain 2 missing values and require consistency checks.

### Sellers

* `seller_id` is unique across all 3,095 seller records.
* The table grain is one row per seller.
* `seller_id` is the candidate primary key.

### Geolocation

* The dataset contains 1,000,163 records.
* Only 19,015 distinct ZIP-code prefixes exist.
* Multiple geolocation records can therefore exist for the same ZIP-code prefix.
* Geolocation must not be treated as a one-to-one ZIP-prefix lookup without further validation.

### Category Translation

* The dataset contains 71 category translation records.
* `product_category_name` is unique.
* The table functions as a category lookup/reference table.

## Scope Note

The local data directory also contains `daily-website-visitors.csv`.

This file is outside the scope of the Olist e-commerce analysis and is not currently included in the analytical pipeline.

## Profiling Status

The dataset structure and candidate keys have been profiled. Further validation is in progress, including:

- Missing-value analysis
- Data-type validation
- Date validation
- Numeric validation
- Referential integrity
- Cross-table reconciliation

## Data Quality Findings

### DQ-REV-001: Non-Unique Review Identifier

**Issue:** `review_id` is not unique in the source review dataset.

**Evidence:**
- 789 review IDs are associated with multiple orders.
- No exact duplicate review rows were identified.

**Impact:** Assuming `review_id` is a unique identifier could lead to incorrect joins or review counts.

**Treatment:** Preserve the raw records. Do not deduplicate solely based on `review_id`. Review metrics must be aggregated at an appropriate analytical grain before joining to order-level or item-level data.

### DQ-ORD-001: Delivered Orders With Missing Timestamps

**Issue:** 16 delivered orders contain a missing approval timestamp or missing carrier delivery timestamp.

**Findings:**
- 14 delivered orders have a missing `order_approved_at`.
- 2 delivered orders have a missing `order_delivered_carrier_date`.
- 1 delivered order has neither a carrier nor customer delivery timestamp.
- 8 delivered orders have a missing `order_delivered_customer_date`.

**Treatment:**
- Missing approval timestamps are retained because they do not prevent delivery-duration calculations when valid delivery timestamps exist.
- Missing carrier timestamps are retained when a valid customer delivery timestamp exists.
- Orders without a valid customer delivery timestamp are excluded from metrics that require actual customer delivery time.
- No timestamps are imputed.

### DQ-ORD-002: Delivered Order With Missing Customer Delivery Timestamp

Eight delivered orders have no `order_delivered_customer_date`.

Seven have a populated carrier delivery timestamp, while one order (`92643`) has neither a carrier nor customer delivery timestamp.

These records are retained in the source data but excluded from calculations requiring actual customer delivery time.

### DQ-PROD-001: Incomplete Product Metadata

**Issue:** 610 products have missing values for `product_category_name`, `product_name_lenght`, `product_description_lenght`, and `product_photos_qty`.

**Evidence:**
- All 610 incomplete products appear in `order_items`.
- These products are associated with 1,603 order-item records.
- Therefore, the incomplete metadata affects products that were actually transacted.

**Impact:** Removing these products would exclude valid transaction records and could understate product-level and category-level metrics.

**Treatment:**
- Retain all product records.
- Preserve NULL values in the raw data.
- Do not impute product categories or descriptive attributes.
- For category-level analytical reporting, NULL categories will be represented as `Unknown / Unclassified`.

### DQ-PROD-002: Missing Product Physical Attributes

**Issue:** Two products have missing values across all four physical attributes: `product_weight_g`, `product_length_cm`, `product_height_cm`, and `product_width_cm`.

**Evidence:**
- Both products appear in transaction data.
- Together they account for 18 order-item records.
- Product `5eb564652db742ff8f28759cd8d2652a` appears in 17 order-item records.
- Product `09ff539a621711667c43eba6a3bd8466` appears in 1 order-item record.

**Impact:** Missing physical attributes can affect logistics and freight-related analysis but do not prevent core sales and revenue calculations.

**Treatment:**
- Retain the products and transaction records.
- Preserve NULL physical attributes in the source data.
- Do not impute weight or dimensions.
- Analyses requiring physical attributes will explicitly account for missing values.

### DQ-PAY-001: Non-Positive Payment Installments

**Issue:** 2 payment records contain `payment_installments = 0`.

**Evidence:**
- Both records have `payment_type = credit_card`.
- Payment values are positive (58.69 and 129.94).
- No negative payment values were identified.

**Impact:** These records cannot reliably be interpreted as valid installment counts for installment-based analysis.

**Treatment:**
- Preserve the raw value of 0.
- Do not impute the installment count.
- Treat these records as invalid/unknown for installment-specific analysis.
- They remain valid payment records for broader payment-value analysis unless another data-quality issue is identified.

### DQ-PROD-003: Zero Product Weight

**Issue:** 4 products contain `product_weight_g = 0`.

**Evidence:**
- All 4 products appear in transaction data.
- Together they account for 8 order-item records.
- The products have populated physical dimensions, but their recorded weight is zero.

**Impact:** Zero weight is not a valid physical value for shipped products and may distort logistics or freight-related analysis.

**Treatment:**
- Retain the products and transaction records.
- Preserve the source value of 0.
- Do not impute or estimate product weight.
- Exclude these records from analyses requiring a valid positive product weight.
- Retain them for sales, revenue, order, and category analysis.