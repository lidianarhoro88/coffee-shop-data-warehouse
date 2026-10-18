# Coffee Shop Data Warehouse Project

A practice data warehousing project built from scratch, following the **Medallion Architecture** (Bronze → Silver → Gold) pattern 

## The story

A fictional coffee shop chain (5 branches across Turkey) runs two separate systems:
- **POS system**: stores, products, sales transactions
- **Loyalty app**: customer accounts, points redemptions

The goal: bring both into one clean, analysis-ready data warehouse, then build an interactive Power BI dashboard on top of it.

## Architecture

```
Raw CSVs (source_pos / source_loyalty)
        │
        ▼
   BRONZE  — raw data landed as-is, no cleaning, nothing assumed
        │
        ▼
   SILVER  — cleaned, typed, deduplicated, business rules applied
        │
        ▼
    GOLD   — star schema (views): dim_customers, dim_products, dim_stores, fact_sales
        │
        ▼
   Power BI — star schema model + interactive dashboard
```

## What makes the source data "realistic"

The data generator (`scripts/generate_source_data.py`) intentionally injects the kind of mess real source systems produce:
- ~20 duplicate customer records (a stale snapshot left behind after an update)
- Inconsistent name casing/spacing (`"  JOHN SMITH  "` vs `"John Smith"`)
- Missing emails and missing loyalty tiers
- A few corrupted sale dates and one stray negative quantity
- ~15% of sales with no loyalty card attached (walk-in customers) — a real NULL, not a data error

Every cleaning rule in the Silver layer scripts exists **because of a specific problem seen in the raw data** — see the comments in `scripts/silver/load_silver.sql`.

## Repository structure

```
coffee-shop-data-warehouse/
├── datasets/
│   ├── source_pos/          stores.csv, products.csv, sales.csv
│   └── source_loyalty/      customers.csv, redemptions.csv
├── scripts/
│   ├── generate_source_data.py   generates the raw CSVs above (Python + Faker)
│   ├── bronze/               DDL + load scripts for the raw landing tables
│   ├── silver/               DDL + cleaning/transformation scripts
│   └── gold/                 star schema views (dim_* and fact_sales)
└── exports_for_powerbi/      gold layer exported as CSV, used to build the Power BI model
```

## How to run it

1. Have a PostgreSQL server running, create a database (e.g. `coffee_dwh`).
2. Generate the raw data: `python3 scripts/generate_source_data.py`
3. Run, in order:
   - `scripts/bronze/ddl_bronze.sql` then `scripts/bronze/load_bronze.sql`
   - `scripts/silver/ddl_silver.sql` then `scripts/silver/load_silver.sql`
   - `scripts/gold/ddl_gold.sql`
4. Query `gold.fact_sales`, `gold.dim_customers`, `gold.dim_products`, `gold.dim_stores` — or export them (as in `exports_for_powerbi/`) and build a Power BI / any BI model on top.

## Power BI dashboard

Built directly on the Gold layer exports: a star schema model (3 dimension tables → 1 fact table), with Total Revenue / Total Units measures, a product revenue bar chart, a customer-tier donut chart, a monthly revenue trend, and a store-city slicer.

## Credit

Built as a hands-on practice project to learn the Medallion Architecture pattern, following the structure taught in [Data With Baraa](https://www.youtube.com/@datawithbaraa)'s course — applied here to an original coffee-shop domain and dataset.
