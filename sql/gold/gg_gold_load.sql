-- =====================================================================
-- GOLD LAYER LOAD
-- Source : ss_silver.*   (typed, cleaned, de-duplicated tables)
-- Target : gg_gold.*     (pre-aggregated, business-ready tables)
--
-- Business rules used throughout (documented here once):
--   - "Valid" sales = silver_transactions.status IN ('completed','refunded')
--     i.e. orders that actually shipped/were paid for. 'cancelled' orders
--     never happened commercially, so they are counted (for visibility)
--     but excluded from revenue/profit/units.
--   - Reference date for "recent activity" windows (customer status,
--     90-day inventory velocity) = MAX(txn_date) in the data, since this
--     is a historical dataset, not a live feed. Replace with CURDATE()
--     if you point this at a live, continuously-updated bb_bronze/ss_silver.
--
-- Requires MySQL 8.0+ / MariaDB 10.2+. Run gg_gold_schema.sql first.
-- =====================================================================

USE gg_gold;

SET SQL_MODE = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';

SET @ref_date := (SELECT MAX(txn_date) FROM ss_silver.silver_transactions);

-- ---------------------------------------------------------------------
-- 1) gold_customer_360
-- ---------------------------------------------------------------------
TRUNCATE TABLE gold_customer_360;
INSERT INTO gold_customer_360
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.country,
  c.currency,
  c.age,
  c.gender,
  c.registration_date,
  c.is_premium,
  COALESCE(t.total_orders, 0),
  COALESCE(t.cancelled_orders, 0),
  COALESCE(t.refunded_orders, 0),
  COALESCE(t.total_units_purchased, 0),
  COALESCE(t.total_revenue_usd, 0),
  COALESCE(t.total_profit_usd, 0),
  CASE WHEN COALESCE(t.total_orders,0) > 0 THEN t.total_revenue_usd / t.total_orders END,
  t.first_order_date,
  t.last_order_date,
  COALESCE(r.total_returns, 0),
  COALESCE(r.total_refunded_usd, 0),
  CASE WHEN COALESCE(t.total_orders,0) > 0
       THEN ROUND(100 * COALESCE(r.total_returns,0) / t.total_orders, 2) END,
  CASE
    WHEN COALESCE(t.total_orders, 0) = 0 THEN 'No Orders'
    WHEN DATEDIFF(@ref_date, t.last_order_date) <= 90  THEN 'Active'
    WHEN DATEDIFF(@ref_date, t.last_order_date) <= 180 THEN 'At Risk'
    ELSE 'Churned'
  END,
  NOW()
FROM ss_silver.silver_customers c
LEFT JOIN (
  SELECT
    customer_id,
    SUM(status = 'completed') AS total_orders,           -- "completed" counted as fulfilled order count
    SUM(status = 'cancelled') AS cancelled_orders,
    SUM(status = 'refunded')  AS refunded_orders,
    SUM(CASE WHEN status IN ('completed','refunded') THEN quantity ELSE 0 END)     AS total_units_purchased,
    SUM(CASE WHEN status IN ('completed','refunded') THEN revenue_usd ELSE 0 END)  AS total_revenue_usd,
    SUM(CASE WHEN status IN ('completed','refunded') THEN profit_usd ELSE 0 END)   AS total_profit_usd,
    MIN(txn_date) AS first_order_date,
    MAX(txn_date) AS last_order_date
  FROM ss_silver.silver_transactions
  GROUP BY customer_id
) t ON t.customer_id = c.customer_id
LEFT JOIN (
  SELECT customer_id, COUNT(*) AS total_returns, SUM(refund_amount_usd) AS total_refunded_usd
  FROM ss_silver.silver_returns
  GROUP BY customer_id
) r ON r.customer_id = c.customer_id;

-- ---------------------------------------------------------------------
-- 2) gold_product_performance
-- ---------------------------------------------------------------------
TRUNCATE TABLE gold_product_performance;
INSERT INTO gold_product_performance
SELECT
  p.product_id,
  p.name,
  p.category,
  p.brand,
  p.unit_price_usd,
  p.unit_cost_usd,
  p.is_active,
  p.launch_date,
  COALESCE(t.total_orders, 0),
  COALESCE(t.total_units_sold, 0),
  COALESCE(t.total_revenue_usd, 0),
  COALESCE(t.total_profit_usd, 0),
  CASE WHEN COALESCE(t.total_revenue_usd,0) > 0
       THEN ROUND(100 * t.total_profit_usd / t.total_revenue_usd, 2) END,
  CASE WHEN COALESCE(t.total_units_sold,0) > 0
       THEN ROUND(t.total_revenue_usd / t.total_units_sold, 2) END,
  COALESCE(r.total_returns, 0),
  COALESCE(r.total_refunded_usd, 0),
  CASE WHEN COALESCE(t.total_units_sold,0) > 0
       THEN ROUND(100 * COALESCE(r.total_returns,0) / t.total_units_sold, 2) END,
  i.stock_units,
  i.reorder_point,
  CASE
    WHEN i.stock_units IS NULL THEN 'No Inventory Data'
    WHEN i.stock_units <= i.reorder_point THEN 'Below Reorder Point'
    ELSE 'OK'
  END,
  sc.supplier_name,
  sc.lead_time_days,
  NOW()
FROM ss_silver.silver_products p
LEFT JOIN (
  SELECT
    product_id,
    SUM(status IN ('completed','refunded')) AS total_orders,
    SUM(CASE WHEN status IN ('completed','refunded') THEN quantity ELSE 0 END)    AS total_units_sold,
    SUM(CASE WHEN status IN ('completed','refunded') THEN revenue_usd ELSE 0 END) AS total_revenue_usd,
    SUM(CASE WHEN status IN ('completed','refunded') THEN profit_usd ELSE 0 END)  AS total_profit_usd
  FROM ss_silver.silver_transactions
  GROUP BY product_id
) t ON t.product_id = p.product_id
LEFT JOIN (
  SELECT product_id, COUNT(*) AS total_returns, SUM(refund_amount_usd) AS total_refunded_usd
  FROM ss_silver.silver_returns
  GROUP BY product_id
) r ON r.product_id = p.product_id
LEFT JOIN ss_silver.silver_inventory i ON i.product_id = p.product_id
LEFT JOIN ss_silver.silver_supplier_costs sc
  ON sc.product_id = p.product_id AND sc.is_primary = 1;

-- ---------------------------------------------------------------------
-- 3) gold_sales_monthly_summary
-- ---------------------------------------------------------------------
TRUNCATE TABLE gold_sales_monthly_summary;
INSERT INTO gold_sales_monthly_summary
SELECT
  DATE_FORMAT(txn_date, '%Y-%m'),
  DATE_FORMAT(txn_date, '%Y-%m-01'),
  SUM(status = 'completed'),
  SUM(status = 'cancelled'),
  SUM(status = 'refunded'),
  SUM(CASE WHEN status IN ('completed','refunded') THEN quantity ELSE 0 END),
  SUM(CASE WHEN status IN ('completed','refunded') THEN revenue_usd ELSE 0 END),
  SUM(CASE WHEN status IN ('completed','refunded') THEN profit_usd ELSE 0 END),
  SUM(CASE WHEN status IN ('completed','refunded') THEN shipping_cost_usd ELSE 0 END),
  COUNT(DISTINCT CASE WHEN status IN ('completed','refunded') THEN customer_id END),
  CASE WHEN SUM(status IN ('completed','refunded')) > 0
       THEN ROUND(SUM(CASE WHEN status IN ('completed','refunded') THEN revenue_usd ELSE 0 END)
                   / SUM(status IN ('completed','refunded')), 2) END,
  NOW()
FROM ss_silver.silver_transactions
GROUP BY DATE_FORMAT(txn_date, '%Y-%m'), DATE_FORMAT(txn_date, '%Y-%m-01');

-- ---------------------------------------------------------------------
-- 4) gold_sales_by_category_channel
-- ---------------------------------------------------------------------
TRUNCATE TABLE gold_sales_by_category_channel;
INSERT INTO gold_sales_by_category_channel
SELECT
  DATE_FORMAT(txn_date, '%Y-%m'),
  category,
  channel,
  SUM(status IN ('completed','refunded')),
  SUM(CASE WHEN status IN ('completed','refunded') THEN quantity ELSE 0 END),
  SUM(CASE WHEN status IN ('completed','refunded') THEN revenue_usd ELSE 0 END),
  SUM(CASE WHEN status IN ('completed','refunded') THEN profit_usd ELSE 0 END),
  COUNT(DISTINCT CASE WHEN status IN ('completed','refunded') THEN customer_id END),
  NOW()
FROM ss_silver.silver_transactions
GROUP BY DATE_FORMAT(txn_date, '%Y-%m'), category, channel;

-- ---------------------------------------------------------------------
-- 5) gold_marketing_performance  (reported spend vs. actual sales outcome)
-- ---------------------------------------------------------------------
TRUNCATE TABLE gold_marketing_performance;
INSERT INTO gold_marketing_performance
SELECT
  m.`year_month`,
  m.channel,
  m.spend_usd,
  m.impressions,
  m.clicks,
  m.ctr,
  m.actual_orders,
  m.actual_customers,
  m.actual_revenue_usd,
  m.roas,
  m.cac_usd,
  COALESCE(a.actual_orders_from_sales, 0),
  COALESCE(a.actual_revenue_from_sales_usd, 0),
  COALESCE(a.actual_customers_from_sales, 0),
  COALESCE(a.actual_revenue_from_sales_usd, 0) - COALESCE(m.actual_revenue_usd, 0),
  CASE WHEN COALESCE(m.actual_revenue_usd, 0) > 0
       THEN ROUND(100 * (COALESCE(a.actual_revenue_from_sales_usd,0) - m.actual_revenue_usd) / m.actual_revenue_usd, 2)
  END,
  NOW()
FROM ss_silver.silver_marketing_spend m
LEFT JOIN (
  SELECT
    DATE_FORMAT(txn_date, '%Y-%m') AS `year_month`,
    channel,
    SUM(status IN ('completed','refunded')) AS actual_orders_from_sales,
    SUM(CASE WHEN status IN ('completed','refunded') THEN revenue_usd ELSE 0 END) AS actual_revenue_from_sales_usd,
    COUNT(DISTINCT CASE WHEN status IN ('completed','refunded') THEN customer_id END) AS actual_customers_from_sales
  FROM ss_silver.silver_transactions
  GROUP BY DATE_FORMAT(txn_date, '%Y-%m'), channel
) a ON a.`year_month` = m.`year_month` AND a.channel = m.channel;

-- ---------------------------------------------------------------------
-- 6) gold_inventory_status
-- ---------------------------------------------------------------------
TRUNCATE TABLE gold_inventory_status;
INSERT INTO gold_inventory_status
SELECT
  p.product_id,
  p.name,
  p.category,
  i.warehouse_location,
  i.stock_units,
  i.reorder_point,
  i.supplier_lead_days,
  v.avg_daily_units_sold_90d,
  CASE WHEN COALESCE(v.avg_daily_units_sold_90d, 0) > 0
       THEN ROUND(i.stock_units / v.avg_daily_units_sold_90d, 1) END,
  CASE
    WHEN i.stock_units IS NULL THEN 'No Inventory Data'
    WHEN i.stock_units = 0 THEN 'Stockout'
    WHEN i.stock_units <= i.reorder_point THEN 'Below Reorder Point'
    ELSE 'Healthy'
  END,
  NOW()
FROM ss_silver.silver_products p
LEFT JOIN ss_silver.silver_inventory i ON i.product_id = p.product_id
LEFT JOIN (
  SELECT product_id, SUM(quantity) / 90.0 AS avg_daily_units_sold_90d
  FROM ss_silver.silver_transactions
  WHERE status IN ('completed','refunded')
    AND txn_date > DATE_SUB(@ref_date, INTERVAL 90 DAY)
  GROUP BY product_id
) v ON v.product_id = p.product_id;

-- ---------------------------------------------------------------------
-- Quick sanity check
-- ---------------------------------------------------------------------
SELECT 'gold_customer_360' AS gold_table, COUNT(*) AS rows_loaded FROM gold_customer_360
UNION ALL SELECT 'gold_product_performance', COUNT(*) FROM gold_product_performance
UNION ALL SELECT 'gold_sales_monthly_summary', COUNT(*) FROM gold_sales_monthly_summary
UNION ALL SELECT 'gold_sales_by_category_channel', COUNT(*) FROM gold_sales_by_category_channel
UNION ALL SELECT 'gold_marketing_performance', COUNT(*) FROM gold_marketing_performance
UNION ALL SELECT 'gold_inventory_status', COUNT(*) FROM gold_inventory_status;
