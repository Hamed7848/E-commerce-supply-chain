-- =====================================================================
-- GOLD LAYER SCHEMA
-- Database: gg_gold   (built from ss_silver, which is built from bb_bronze)
-- Purpose : business-ready, pre-aggregated tables for BI / dashboards
--           (Power BI, Excel, reporting). No raw/typed data here - that's
--           Silver's job. Gold = "ready to plug into a chart".
-- =====================================================================

CREATE DATABASE IF NOT EXISTS gg_gold
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE gg_gold;

-- ---------------------------------------------------------------------
-- gold_customer_360
-- One row per customer: profile + lifetime purchase & return behaviour.
-- ---------------------------------------------------------------------
DROP Table IF EXISTS gold_customer_360;
CREATE Table gold_customer_360 (
  customer_id             VARCHAR(20) NOT NULL,
  first_name               VARCHAR(100),
  last_name                VARCHAR(100),
  country                  VARCHAR(100),
  currency                 CHAR(3),
  age                      TINYINT UNSIGNED,
  gender                   VARCHAR(10),
  registration_date        DATE,
  is_premium                TINYINT(1),
  total_orders               INT DEFAULT 0,          -- status = completed
  cancelled_orders            INT DEFAULT 0,
  refunded_orders              INT DEFAULT 0,
  total_units_purchased          INT DEFAULT 0,
  total_revenue_usd                DECIMAL(14,2) DEFAULT 0,
  total_profit_usd                  DECIMAL(14,2) DEFAULT 0,
  avg_order_value_usd                 DECIMAL(10,2),
  first_order_date                     DATE,
  last_order_date                       DATE,
  total_returns                          INT DEFAULT 0,
  total_refunded_usd                      DECIMAL(12,2) DEFAULT 0,
  return_rate_pct                          DECIMAL(6,2),
  customer_status                           VARCHAR(20),   -- Active / At Risk / Churned / No Orders
  _gold_loaded_at                            DATETIME NOT NULL,
  PRIMARY KEY (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- gold_product_performance
-- One row per product: sales, margin, returns, stock health.
-- ---------------------------------------------------------------------
DROP Table IF EXISTS gold_product_performance;
CREATE Table gold_product_performance (
  product_id                  VARCHAR(20) NOT NULL,
  name                          VARCHAR(255),
  category                       VARCHAR(100),
  brand                           VARCHAR(100),
  unit_price_usd                   DECIMAL(10,2),
  unit_cost_usd                     DECIMAL(10,2),
  is_active                          TINYINT(1),
  launch_date                         DATE,
  total_orders                         INT DEFAULT 0,
  total_units_sold                       INT DEFAULT 0,
  total_revenue_usd                        DECIMAL(14,2) DEFAULT 0,
  total_profit_usd                           DECIMAL(14,2) DEFAULT 0,
  gross_margin_pct                             DECIMAL(6,2),
  avg_selling_price_usd                          DECIMAL(10,2),
  total_returns                                    INT DEFAULT 0,
  total_refunded_usd                                 DECIMAL(12,2) DEFAULT 0,
  return_rate_pct                                      DECIMAL(6,2),
  current_stock_units                                    INT,
  reorder_point                                            INT,
  stock_status                                              VARCHAR(30),  -- Below Reorder / OK / No Inventory Data
  primary_supplier_name                                       VARCHAR(100),
  primary_supplier_lead_time_days                               INT,
  _gold_loaded_at                                                DATETIME NOT NULL,
  PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- gold_sales_monthly_summary
-- One row per calendar month: company-wide sales KPIs.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS gold_sales_monthly_summary;
CREATE TABLE gold_sales_monthly_summary (
  `year_month`             CHAR(7) NOT NULL,
  month_start_date          DATE,
  total_orders                INT DEFAULT 0,
  cancelled_orders              INT DEFAULT 0,
  refunded_orders                 INT DEFAULT 0,
  total_units                       INT DEFAULT 0,
  total_revenue_usd                   DECIMAL(14,2) DEFAULT 0,
  total_profit_usd                      DECIMAL(14,2) DEFAULT 0,
  total_shipping_cost_usd                 DECIMAL(12,2) DEFAULT 0,
  distinct_customers                        INT DEFAULT 0,
  avg_order_value_usd                         DECIMAL(10,2),
  _gold_loaded_at                               DATETIME NOT NULL,
  PRIMARY KEY (`year_month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- gold_sales_by_category_channel
-- One row per (month, category, channel): sales breakdown for slicing.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS gold_sales_by_category_channel;
CREATE TABLE gold_sales_by_category_channel (
  `year_month`      CHAR(7) NOT NULL,
  category            VARCHAR(100) NOT NULL,
  channel               VARCHAR(50) NOT NULL,
  total_orders            INT DEFAULT 0,
  total_units                INT DEFAULT 0,
  total_revenue_usd             DECIMAL(14,2) DEFAULT 0,
  total_profit_usd                DECIMAL(14,2) DEFAULT 0,
  distinct_customers                 INT DEFAULT 0,
  _gold_loaded_at                      DATETIME NOT NULL,
  PRIMARY KEY (`year_month`, category, channel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- gold_marketing_performance
-- One row per (month, channel): reported marketing KPIs, reconciled
-- against what actually shows up in the sales/transactions data.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS gold_marketing_performance;
CREATE TABLE gold_marketing_performance (
  `year_month`             CHAR(7) NOT NULL,
  channel                    VARCHAR(50) NOT NULL,
  spend_usd                    DECIMAL(14,2),
  impressions                    INT,
  clicks                           INT,
  ctr                                DECIMAL(8,4),
  reported_orders                     INT,
  reported_customers                    INT,
  reported_revenue_usd                    DECIMAL(14,2),
  roas                                      DECIMAL(10,3),
  cac_usd                                    DECIMAL(10,2),
  actual_orders_from_sales                     INT,
  actual_revenue_from_sales_usd                  DECIMAL(14,2),
  actual_customers_from_sales                      INT,
  revenue_variance_usd                               DECIMAL(14,2),
  revenue_variance_pct                                 DECIMAL(6,2),
  _gold_loaded_at                                        DATETIME NOT NULL,
  PRIMARY KEY (`year_month`, channel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- gold_inventory_status
-- One row per product: current stock health & days-of-supply.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS gold_inventory_status;
CREATE TABLE gold_inventory_status (
  product_id                    VARCHAR(20) NOT NULL,
  name                            VARCHAR(255),
  category                          VARCHAR(100),
  warehouse_location                  VARCHAR(50),
  stock_units                           INT,
  reorder_point                           INT,
  supplier_lead_days                        INT,
  avg_daily_units_sold_90d                    DECIMAL(8,3),
  days_of_supply                                DECIMAL(8,1),
  stock_status                                    VARCHAR(30), -- Stockout / Below Reorder Point / Healthy
  _gold_loaded_at                                   DATETIME NOT NULL,
  PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_gold_sbc_category ON gold_sales_by_category_channel(category);
CREATE INDEX idx_gold_sbc_channel  ON gold_sales_by_category_channel(channel);
CREATE INDEX idx_gold_cust_status  ON gold_customer_360(customer_status);
CREATE INDEX idx_gold_prod_stock   ON gold_inventory_status(stock_status);
