# Data Quality Report

## Overview

Data quality checks were performed across the Olist Brazilian E-Commerce dataset to identify issues that could affect analytical accuracy, joins, KPI calculations, and downstream reporting.

The approach is to retain source records wherever possible and explicitly document exceptions rather than silently deleting or imputing data.

## Key Data Quality Findings

### DQ-REV-001: Non-Unique Review Identifier

**Issue:** `review_id` is not unique in the source review dataset.

**Finding:**
- 789 review IDs are associated with multiple orders.
- No exact duplicate review rows were identified.

**Impact:** Treating `review_id` as a unique identifier could result in incorrect joins or review counts.

**Treatment:**
- Preserve the raw records.
- Do not deduplicate solely using `review_id`.
- Aggregate review data at the appropriate analytical grain before joining with other datasets.

### DQ-ORD-001: Delivered Orders With Missing Timestamps

**Issue:** Some orders marked as delivered contain missing lifecycle timestamps.

**Finding:**
- 14 delivered orders have a missing `order_approved_at`.
- 2 delivered orders have a missing `order_delivered_carrier_date`.
- 8 delivered orders have a missing `order_delivered_customer_date`.

**Impact:** Missing delivery timestamps can affect delivery-duration and delivery-timeliness calculations.

**Treatment:**
- Retain the source records.
- Do not impute missing timestamps.
- Exclude records without a valid customer delivery timestamp from calculations requiring actual delivery time.

### DQ-ORD-002: Delivered Orders Missing Customer Delivery Timestamp

Eight delivered orders have no `order_delivered_customer_date`.

Seven have a populated carrier delivery timestamp, while one order has neither a carrier nor customer delivery timestamp.

**Treatment:**
- Retain the records in the source data.
- Exclude records without a valid customer delivery timestamp from metrics requiring actual customer delivery time.
- Do not impute delivery timestamps.

### DQ-PROD-001: Incomplete Product Metadata

**Issue:** 610 products have missing values across product category and descriptive metadata fields.

**Finding:**
- The incomplete products appear in transaction data.
- Removing them would exclude valid transactions from analysis.

**Impact:** Deleting these products could understate product-level and category-level metrics.

**Treatment:**
- Retain all product records.
- Preserve NULL values.
- Do not impute missing product attributes.
- Represent missing categories as `Unknown / Unclassified` where required for category-level reporting.

### DQ-PROD-002: Missing Product Physical Attributes

**Issue:** Two products have missing values across all four physical attributes.

**Impact:** Missing physical attributes can affect logistics and freight-related analysis.

**Treatment:**
- Retain the products and transaction records.
- Preserve NULL values.
- Do not impute physical attributes.
- Explicitly account for missing values in analyses requiring these attributes.

### DQ-PAY-001: Non-Positive Payment Installments

**Issue:** Two payment records contain `payment_installments = 0`.

**Finding:**
- Both records use `credit_card`.
- Payment values are positive.

**Impact:** These records cannot reliably be interpreted as valid installment counts.

**Treatment:**
- Preserve the source value of 0.
- Do not impute the installment count.
- Treat the installment count as invalid/unknown for installment-specific analysis.
- Retain the records for broader payment-value analysis.

### DQ-PROD-003: Zero Product Weight

**Issue:** Four products contain `product_weight_g = 0`.

**Impact:** Zero weight may distort logistics or freight-related analysis.

**Treatment:**
- Retain the products and transaction records.
- Preserve the source value.
- Do not impute product weight.
- Exclude these records from analyses requiring a valid positive weight.
- Retain them for sales, revenue, order, and category analysis.

## Data Quality Principles

The project follows these principles:

1. **Preserve source data** wherever possible.
2. **Do not silently delete records** because of missing or unusual values.
3. **Do not impute values without a defensible business rule.**
4. **Validate missing values against business context**, such as order lifecycle status.
5. **Use the correct analytical grain** before joining datasets.
6. **Document exceptions and their treatment** so analytical results remain reproducible.

## Status

The identified issues have been documented and their treatment has been defined for downstream analysis.

Further validation can be performed as the project evolves, particularly for referential integrity, date consistency, and cross-table reconciliation.
