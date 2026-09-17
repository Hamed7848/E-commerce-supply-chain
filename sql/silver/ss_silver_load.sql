-- =====================================================================
-- SILVER LAYER LOAD
-- Source : bb_bronze.*   (raw VARCHAR tables)
-- Target : ss_silver.*   (typed, cleaned, de-duplicated tables)
--
-- What this does for every table:
--   1. Casts each column to its real type (DATE, INT, DECIMAL, BOOLEAN)
--   2. Trims text and turns '' into NULL
--   3. Drops rows with a missing/blank natural key
--   4. De-duplicates: if the same natural key appears more than once
--      (e.g. re-run ingestion), keeps only the most recently inserted
--      row (ROW_NUMBER() OVER (... ORDER BY bronze_id DESC), since
--      bronze_id is an AUTO_INCREMENT surrogate key - highest id = latest)
--
-- Requires MySQL 8.0+ (window functions). Run ss_silver_schema.sql first.
-- Run this with a user that has SELECT on bb_bronze and INSERT on ss_silver.
-- =====================================================================

USE ss_silver;

SET SQL_MODE = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';

-- ---------------------------------------------------------------------
-- 1) silver_customers
-- ---------------------------------------------------------------------
TRUNCATE TABLE silver_customers;
INSERT INTO silver_customers
SELECT
  customer_id,
  NULLIF(TRIM(first_name), ''),
  NULLIF(TRIM(last_name), ''),
  NULLIF(TRIM(country), ''),
  NULLIF(TRIM(currency), ''),
  CAST(NULLIF(TRIM(age), '') AS UNSIGNED),
  case when TRIM(nullif(gender,''))='F' then 'Female' when TRIM(nullif(gender,''))='M' then 'Male' end,
  STR_TO_DATE(NULLIF(TRIM(registration_date), ''), '%Y-%m-%d'),
  CASE WHEN TRIM(is_premium) = 'True' THEN 1 WHEN TRIM(is_premium) = 'False' THEN 0 END,
  CASE WHEN TRIM(email_verified) = 'True' THEN 1 WHEN TRIM(email_verified) = 'False' THEN 0 END,
  LOWER(NULLIF(TRIM(email), '')),
  NULL, -- _bronze_batch_id: not available (source bronze tables have no batch tracking column)
  NOW()
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY bronze_id DESC) AS rn
  FROM bb_bronze.bronze_customers b
  WHERE NULLIF(TRIM(customer_id), '') IS NOT NULL
) d
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- 2) silver_products  (load before inventory/supplier_costs/price_history: FK dependency)
-- ---------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE silver_inventory;
TRUNCATE TABLE silver_supplier_costs;
TRUNCATE TABLE silver_price_history;
TRUNCATE TABLE silver_products;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO silver_products
SELECT
  product_id,
  NULLIF(TRIM(name), ''),
  NULLIF(TRIM(category), ''),
  NULLIF(TRIM(brand), ''),
  CAST(NULLIF(TRIM(unit_price_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(unit_cost_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(weight_kg), '') AS DECIMAL(6,2)),
  CASE WHEN TRIM(is_active) = 'True' THEN 1 WHEN TRIM(is_active) = 'False' THEN 0 END,
  STR_TO_DATE(NULLIF(TRIM(launch_date), ''), '%Y-%m-%d'),
  NULL, -- _bronze_batch_id: not available (source bronze tables have no batch tracking column)
  NOW()
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY bronze_id DESC) AS rn
  FROM bb_bronze.bronze_products b
  WHERE NULLIF(TRIM(product_id), '') IS NOT NULL
) d
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- 3) silver_inventory
-- ---------------------------------------------------------------------
INSERT INTO silver_inventory
SELECT
  product_id,
  NULLIF(TRIM(category), ''),
  CAST(NULLIF(TRIM(stock_units), '') AS SIGNED),
  CAST(NULLIF(TRIM(reorder_point), '') AS SIGNED),
  NULLIF(TRIM(warehouse_location), ''),
  STR_TO_DATE(NULLIF(TRIM(last_restock_date), ''), '%Y-%m-%d'),
  CAST(NULLIF(TRIM(supplier_lead_days), '') AS SIGNED),
  NULL, -- _bronze_batch_id: not available (source bronze tables have no batch tracking column)
  NOW()
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY bronze_id DESC) AS rn
  FROM bb_bronze.bronze_inventory b
  WHERE NULLIF(TRIM(product_id), '') IS NOT NULL
    AND TRIM(product_id) IN (SELECT product_id FROM silver_products)
) d
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- 4) silver_supplier_costs
-- ---------------------------------------------------------------------
INSERT INTO silver_supplier_costs
SELECT
  product_id,
  NULLIF(TRIM(category), ''),
  supplier_name,
  CAST(NULLIF(TRIM(supplier_rank), '') AS SIGNED),
  CAST(NULLIF(TRIM(unit_cost_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(ordering_cost_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(annual_holding_cost_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(holding_cost_pct), '') AS DECIMAL(6,4)),
  CAST(NULLIF(TRIM(lead_time_days), '') AS SIGNED),
  CAST(NULLIF(TRIM(min_order_qty), '') AS SIGNED),
  CAST(NULLIF(TRIM(reliability_score), '') AS DECIMAL(4,2)),
  CASE WHEN TRIM(is_primary) = 'True' THEN 1 WHEN TRIM(is_primary) = 'False' THEN 0 END,
  NULL, -- _bronze_batch_id: not available (source bronze tables have no batch tracking column)
  NOW()
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY product_id, supplier_name ORDER BY bronze_id DESC) AS rn
  FROM bb_bronze.bronze_supplier_costs b
  WHERE NULLIF(TRIM(product_id), '') IS NOT NULL
    AND NULLIF(TRIM(supplier_name), '') IS NOT NULL
    AND TRIM(product_id) IN (SELECT product_id FROM silver_products)
) d
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- 5) silver_marketing_spend
-- ---------------------------------------------------------------------
TRUNCATE TABLE silver_marketing_spend;
INSERT INTO silver_marketing_spend
SELECT
  `year_month`,
  STR_TO_DATE(CONCAT(`year_month`, '-01'), '%Y-%m-%d'),
  NULLIF(TRIM(channel), ''),
  CAST(NULLIF(TRIM(spend_usd), '') AS DECIMAL(14,2)),
  CAST(NULLIF(TRIM(impressions), '') AS SIGNED),
  CAST(NULLIF(TRIM(clicks), '') AS SIGNED),
  CAST(NULLIF(TRIM(ctr), '') AS DECIMAL(8,4)),
  CAST(NULLIF(TRIM(actual_orders), '') AS SIGNED),
  CAST(NULLIF(TRIM(actual_customers), '') AS SIGNED),
  CAST(NULLIF(TRIM(actual_revenue_usd), '') AS DECIMAL(14,2)),
  CAST(NULLIF(TRIM(roas), '') AS DECIMAL(10,3)),
  CAST(NULLIF(TRIM(cac_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(cost_per_order_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(month_multiplier), '') AS DECIMAL(6,2)),
  NULL, -- _bronze_batch_id: not available (source bronze tables have no batch tracking column)
  NOW()
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY `year_month`, channel ORDER BY bronze_id DESC) AS rn
  FROM bb_bronze.bronze_marketing_spend b
  WHERE NULLIF(TRIM(`year_month`), '') IS NOT NULL
    AND NULLIF(TRIM(channel), '') IS NOT NULL
) d
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- 6) silver_price_history
-- ---------------------------------------------------------------------
INSERT INTO silver_price_history
SELECT
  product_id,
  NULLIF(TRIM(category), ''),
  `year_month`,
  STR_TO_DATE(CONCAT(`year_month`, '-01'), '%Y-%m-%d'),
  CAST(NULLIF(TRIM(listed_price_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(base_price_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(competitor_price_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(price_index), '') AS DECIMAL(6,3)),
  CASE WHEN TRIM(is_promotional) = 'True' THEN 1 WHEN TRIM(is_promotional) = 'False' THEN 0 END,
  CAST(NULLIF(TRIM(price_elasticity), '') AS DECIMAL(6,3)),
  CAST(NULLIF(TRIM(units_sold), '') AS SIGNED),
  CAST(NULLIF(TRIM(revenue_usd), '') AS DECIMAL(12,2)),
  CAST(NULLIF(TRIM(margin_pct), '') AS DECIMAL(6,4)),
  NULL, -- _bronze_batch_id: not available (source bronze tables have no batch tracking column)
  NOW()
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY product_id, `year_month` ORDER BY bronze_id DESC) AS rn
  FROM bb_bronze.bronze_price_history b
  WHERE NULLIF(TRIM(product_id), '') IS NOT NULL
    AND NULLIF(TRIM(`year_month`), '') IS NOT NULL
    AND TRIM(product_id) IN (SELECT product_id FROM silver_products)
) d
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- 7) silver_returns
-- ---------------------------------------------------------------------
TRUNCATE TABLE silver_returns;
INSERT INTO silver_returns
SELECT
  return_id,
  NULLIF(TRIM(transaction_id), ''),
  NULLIF(TRIM(customer_id), ''),
  NULLIF(TRIM(product_id), ''),
  STR_TO_DATE(NULLIF(TRIM(return_date), ''), '%Y-%m-%d'),
  NULLIF(TRIM(reason), ''),
  CAST(NULLIF(TRIM(refund_amount_usd), '') AS DECIMAL(10,2)),
  CASE WHEN TRIM(restocked) = 'True' THEN 1 WHEN TRIM(restocked) = 'False' THEN 0 END,
  NULL, -- _bronze_batch_id: not available (source bronze tables have no batch tracking column)
  NOW()
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY return_id ORDER BY bronze_id DESC) AS rn
  FROM bb_bronze.bronze_returns b
  WHERE NULLIF(TRIM(return_id), '') IS NOT NULL
) d
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- 8) silver_transactions
-- ---------------------------------------------------------------------
TRUNCATE TABLE silver_transactions;
INSERT INTO silver_transactions
SELECT
  transaction_id,
  NULLIF(TRIM(customer_id), ''),
  NULLIF(TRIM(product_id), ''),
  STR_TO_DATE(NULLIF(TRIM(`date`), ''), '%Y-%m-%d'),
  CAST(NULLIF(TRIM(quantity), '') AS SIGNED),
  CAST(NULLIF(TRIM(unit_price_usd), '') AS DECIMAL(10,2)),
  CAST(NULLIF(TRIM(discount_pct), '') AS DECIMAL(6,4)),
  CAST(NULLIF(TRIM(revenue_usd), '') AS DECIMAL(12,2)),
  CAST(NULLIF(TRIM(cost_usd), '') AS DECIMAL(12,2)),
  CAST(NULLIF(TRIM(profit_usd), '') AS DECIMAL(12,2)),
  CAST(NULLIF(TRIM(shipping_cost_usd), '') AS DECIMAL(10,2)),
  NULLIF(TRIM(channel), ''),
  NULLIF(TRIM(payment_method), ''),
  NULLIF(TRIM(status), ''),
  NULLIF(TRIM(country), ''),
  NULLIF(TRIM(category), ''),
  NULL, -- _bronze_batch_id: not available (source bronze tables have no batch tracking column)
  NOW()
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY bronze_id DESC) AS rn
  FROM bb_bronze.bronze_transactions b
  WHERE NULLIF(TRIM(transaction_id), '') IS NOT NULL
) d
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- Quick row-count check (source bronze vs loaded silver)
-- ---------------------------------------------------------------------
SELECT 'customers'        AS layer, (SELECT COUNT(*) FROM bb_bronze.bronze_customers)       AS bronze_rows, (SELECT COUNT(*) FROM silver_customers)       AS silver_rows
UNION ALL
SELECT 'products',         (SELECT COUNT(*) FROM bb_bronze.bronze_products),       (SELECT COUNT(*) FROM silver_products)
UNION ALL
SELECT 'inventory',        (SELECT COUNT(*) FROM bb_bronze.bronze_inventory),      (SELECT COUNT(*) FROM silver_inventory)
UNION ALL
SELECT 'supplier_costs',   (SELECT COUNT(*) FROM bb_bronze.bronze_supplier_costs), (SELECT COUNT(*) FROM silver_supplier_costs)
UNION ALL
SELECT 'marketing_spend',  (SELECT COUNT(*) FROM bb_bronze.bronze_marketing_spend),(SELECT COUNT(*) FROM silver_marketing_spend)
UNION ALL
SELECT 'price_history',    (SELECT COUNT(*) FROM bb_bronze.bronze_price_history),  (SELECT COUNT(*) FROM silver_price_history)
UNION ALL
SELECT 'returns',          (SELECT COUNT(*) FROM bb_bronze.bronze_returns),        (SELECT COUNT(*) FROM silver_returns)
UNION ALL
SELECT 'transactions',     (SELECT COUNT(*) FROM bb_bronze.bronze_transactions),   (SELECT COUNT(*) FROM silver_transactions);
