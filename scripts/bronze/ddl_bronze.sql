-- ============================================================
-- Bronze layer: raw tables, same shape as the source CSVs.
-- No cleaning here. If it's broken in the source, it's broken here too.
-- Rule of the Bronze layer: never transform, only land the data.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS bronze;

DROP TABLE IF EXISTS bronze.pos_stores;
CREATE TABLE bronze.pos_stores (
    store_id    TEXT,
    store_name  TEXT,
    city        TEXT
);

DROP TABLE IF EXISTS bronze.pos_products;
CREATE TABLE bronze.pos_products (
    product_id    TEXT,
    product_name  TEXT,
    category      TEXT,
    unit_price    TEXT   -- kept as TEXT on purpose: bronze never assumes the source is clean
);

DROP TABLE IF EXISTS bronze.pos_sales;
CREATE TABLE bronze.pos_sales (
    sale_id              TEXT,
    store_id             TEXT,
    product_id           TEXT,
    customer_loyalty_id  TEXT,
    quantity             TEXT,
    sale_date            TEXT
);

DROP TABLE IF EXISTS bronze.loyalty_customers;
CREATE TABLE bronze.loyalty_customers (
    customer_loyalty_id  TEXT,
    full_name            TEXT,
    email                TEXT,
    city                 TEXT,
    join_date            TEXT,
    tier                 TEXT
);

DROP TABLE IF EXISTS bronze.loyalty_redemptions;
CREATE TABLE bronze.loyalty_redemptions (
    redemption_id        TEXT,
    customer_loyalty_id  TEXT,
    points_used          TEXT,
    redeem_date           TEXT
);
