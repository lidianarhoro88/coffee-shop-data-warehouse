-- ============================================================
-- Loads the raw CSVs straight into the bronze tables.
-- \copy runs on the CLIENT side, so the path is relative to wherever
-- you launch psql from (here: the project root).
-- ============================================================

TRUNCATE TABLE bronze.pos_stores;
\copy bronze.pos_stores FROM 'datasets/source_pos/stores.csv' WITH (FORMAT csv, HEADER true);

TRUNCATE TABLE bronze.pos_products;
\copy bronze.pos_products FROM 'datasets/source_pos/products.csv' WITH (FORMAT csv, HEADER true);

TRUNCATE TABLE bronze.pos_sales;
\copy bronze.pos_sales FROM 'datasets/source_pos/sales.csv' WITH (FORMAT csv, HEADER true);

TRUNCATE TABLE bronze.loyalty_customers;
\copy bronze.loyalty_customers FROM 'datasets/source_loyalty/customers.csv' WITH (FORMAT csv, HEADER true);

TRUNCATE TABLE bronze.loyalty_redemptions;
\copy bronze.loyalty_redemptions FROM 'datasets/source_loyalty/redemptions.csv' WITH (FORMAT csv, HEADER true);
