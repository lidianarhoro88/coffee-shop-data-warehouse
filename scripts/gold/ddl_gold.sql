-- ============================================================
-- Gold layer: business-ready star schema, built as VIEWS on top
-- of silver (same pattern Baraa's course uses: gold = views, not
-- copied tables — always reflects the latest silver data, no extra
-- storage, and if silver changes, gold updates automatically).
--
-- Star schema shape:
--        dim_customers
--             |
--   dim_products -- fact_sales -- dim_stores
--
-- fact_sales holds the MEASURES (what we count/sum: quantity, revenue).
-- dim_* tables hold the DESCRIPTIVE attributes you slice/filter by.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS gold;

DROP VIEW IF EXISTS gold.dim_customers;
CREATE VIEW gold.dim_customers AS
SELECT
    customer_loyalty_id AS customer_key,
    full_name,
    email,
    city                AS customer_city,
    join_date,
    tier
FROM silver.loyalty_customers;

DROP VIEW IF EXISTS gold.dim_products;
CREATE VIEW gold.dim_products AS
SELECT
    product_id AS product_key,
    product_name,
    category,
    unit_price
FROM silver.pos_products;

DROP VIEW IF EXISTS gold.dim_stores;
CREATE VIEW gold.dim_stores AS
SELECT
    store_id AS store_key,
    store_name,
    city     AS store_city
FROM silver.pos_stores;

DROP VIEW IF EXISTS gold.fact_sales;
CREATE VIEW gold.fact_sales AS
SELECT
    s.sale_id,
    s.store_id            AS store_key,
    s.product_id           AS product_key,
    s.customer_loyalty_id  AS customer_key,     -- NULL for walk-ins with no loyalty card
    s.sale_date,
    s.quantity,
    p.unit_price,
    s.quantity * p.unit_price AS revenue         -- the measure we didn't have in silver: computed here, in gold
FROM silver.pos_sales s
JOIN silver.pos_products p ON p.product_id = s.product_id;
