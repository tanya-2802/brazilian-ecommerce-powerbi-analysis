# Brazilian E-Commerce Data Analysis & Power BI Dashboard

End-to-end analysis of the **Brazilian E-Commerce Public Dataset by Olist**, using Python, SQL, and Power BI to profile data, validate data quality, perform analysis, and build an interactive business dashboard.

## Project Objective

Analyze e-commerce performance across:

- Revenue and orders
- Product categories
- Payment methods
- Customer reviews
- Delivery performance
- Key business KPIs

## Tools

- **Python**: Data profiling and quality analysis
- **SQL**: Data loading, validation, analysis, and analytical views
- **Power BI**: Data modeling, KPIs, visualization, and interactive dashboard
- **Git/GitHub**: Version control and documentation

## Project Workflow

**Raw Data → Python Profiling → Data Quality Validation → SQL Analysis → Analytical Views → Power BI Model → Dashboard → Business Insights**

## Dashboard

The Power BI dashboard includes:

- Total Revenue
- Total Orders
- Average Order Value
- Monthly Revenue Trend
- Revenue by Product Category
- Payment Value by Method
- Customer Review Distribution
- Delivery Status Distribution
- Date Range filter
- Product Category filter
- Payment Type filter
- Reset Filters interaction
- Key Takeaways section

## Data Quality

The project includes documented validation of:

- Duplicate and non-unique identifiers
- Missing order lifecycle timestamps
- Incomplete product metadata
- Missing product physical attributes
- Invalid payment installment values
- Zero product weights

Data-quality issues are documented with their impact and treatment rather than being silently removed or imputed.

See [`documentation/data_quality.md`](documentation/data_quality.md).

## Repository Structure

```text
Brazilian-Ecommerce-BI/
├── data/             # Source and prepared datasets
├── documentation/    # Data dictionary and data-quality report
├── powerbi/          # Power BI PBIP project
├── python/           # Python profiling notebook
├── sql/              # SQL tables, validation, analysis and views
├── .gitignore
└── README.md 
``` 
## Outcome

This project demonstrates practical experience in data profiling, data quality validation, SQL analysis, data modeling, Power BI dashboard development, KPI reporting, and business-focused data interpretation.