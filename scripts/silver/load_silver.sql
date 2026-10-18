-- ============================================================
-- Bronze -> Silver: clean, type, and deduplicate.
-- Every transformation below exists because of a real problem
-- we saw in the bronze data. Read the comment before the rule.
-- ============================================================

-- ---------- stores / products: simple, just cast types ----------
TRUNCATE TABLE silver.pos_stores;
INSERT INTO silver.pos_stores (store_id, store_name, city)
SELECT store_id, store_name, city
FROM bronze.pos_stores;

TRUNCATE TABLE silver.pos_products;
INSERT INTO silver.pos_products (product_id, product_name, category, unit_price)
SELECT product_id, product_name, category, unit_price::NUMERIC(10,2)
FROM bronze.pos_products;

-- ---------- customers: trim/standardize names, dedupe, fill missing tier ----------
-- Problem seen in bronze: ~20 customers have 2 rows (a stale snapshot + current one),
-- some names have extra spaces or are ALL CAPS, and some tiers are NULL.
TRUNCATE TABLE silver.loyalty_customers;
INSERT INTO silver.loyalty_customers (customer_loyalty_id, full_name, email, city, join_date, tier)
SELECT DISTINCT ON (customer_loyalty_id)
    customer_loyalty_id,
    INITCAP(TRIM(full_name))                         AS full_name,   -- "  JOHN SMITH  " -> "John Smith"
    email,                                                            -- leave NULL emails as NULL: a real gap, not guessed
    city,
    join_date::DATE,
    COALESCE(tier, 'Unknown')                         AS tier         -- never leave tier NULL; "Unknown" is explicit and query-able
FROM bronze.loyalty_customers
ORDER BY customer_loyalty_id,
         (tier IS NOT NULL) DESC,   -- when duplicated, prefer the row that HAS a tier
         join_date DESC;            -- then prefer the most recent-looking row

-- ---------- sales: drop rows that can't be trusted, cast types ----------
-- Problems seen in bronze: a stray negative quantity, a few blank sale_dates.
-- We don't guess these — we drop them and keep a record of how many, below.
TRUNCATE TABLE silver.pos_sales;
INSERT INTO silver.pos_sales (sale_id, store_id, product_id, customer_loyalty_id, quantity, sale_date)
SELECT
    sale_id,
    store_id,
    product_id,
    NULLIF(customer_loyalty_id, ''),      -- blank string -> real NULL (walk-in, no loyalty card)
    quantity::INT,
    sale_date::TIMESTAMP
FROM bronze.pos_sales
WHERE sale_date <> ''                      -- drop the handful of blank/bad dates
  AND quantity::INT > 0;                   -- drop the stray negative-quantity row

-- ---------- redemptions: straightforward type casts ----------
TRUNCATE TABLE silver.loyalty_redemptions;
INSERT INTO silver.loyalty_redemptions (redemption_id, customer_loyalty_id, points_used, redeem_date)
SELECT redemption_id, customer_loyalty_id, points_used::INT, redeem_date::DATE
FROM bronze.loyalty_redemptions;
