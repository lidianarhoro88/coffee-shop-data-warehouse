-- ============================================================
-- Silver layer: cleaned, typed, deduplicated tables.
-- This is where TEXT becomes a real DATE, a real NUMERIC,
-- names get trimmed, and duplicates get resolved to one row.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.pos_stores;
CREATE TABLE silver.pos_stores (
    store_id    TEXT PRIMARY KEY,
    store_name  TEXT,
    city        TEXT
);

DROP TABLE IF EXISTS silver.pos_products;
CREATE TABLE silver.pos_products (
    product_id    TEXT PRIMARY KEY,
    product_name  TEXT,
    category      TEXT,
    unit_price    NUMERIC(10,2)
);

DROP TABLE IF EXISTS silver.pos_sales;
CREATE TABLE silver.pos_sales (
    sale_id              TEXT PRIMARY KEY,
    store_id             TEXT,
    product_id           TEXT,
    customer_loyalty_id  TEXT,          -- kept NULL-able: not every sale is tied to a loyalty member
    quantity             INT,
    sale_date            TIMESTAMP
);

DROP TABLE IF EXISTS silver.loyalty_customers;
CREATE TABLE silver.loyalty_customers (
    customer_loyalty_id  TEXT PRIMARY KEY,
    full_name            TEXT,
    email                TEXT,
    city                 TEXT,
    join_date            DATE,
    tier                 TEXT          -- unknown tiers resolved to 'Unknown', never left NULL
);

DROP TABLE IF EXISTS silver.loyalty_redemptions;
CREATE TABLE silver.loyalty_redemptions (
    redemption_id        TEXT PRIMARY KEY,
    customer_loyalty_id  TEXT,
    points_used          INT,
    redeem_date           DATE
);
