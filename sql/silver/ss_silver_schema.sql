-- =====================================================================
-- SILVER LAYER SCHEMA
-- Database: ss_silver   (built from bb_bronze)
-- Purpose : typed, cleaned, de-duplicated, conformed tables.
--           Raw/untyped data lives in bb_bronze; business aggregates
--           belong to a later Gold layer, not here.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS ss_silver
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ss_silver;

-- ---------------------------------------------------------------------
-- silver_customers  (from bb_bronze.bronze_customers)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS silver_customers;
CREATE TABLE silver_customers (
  customer_id         VARCHAR(20)  NOT NULL,
  first_name          VARCHAR(100),
  last_name           VARCHAR(100),
  country             VARCHAR(100),
  currency            CHAR(3),
  age                 TINYINT UNSIGNED,
  gender              VARCHAR(10),
  registration_date   DATE,
  is_premium          TINYINT(1),
  email_verified      TINYINT(1),
  email               VARCHAR(255),
  _bronze_batch_id    CHAR(36),
  _silver_loaded_at   DATETIME NOT NULL,
  PRIMARY KEY (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- silver_products  (from bb_bronze.bronze_products)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS silver_products;
CREATE TABLE silver_products (
  product_id          VARCHAR(20)  NOT NULL,
  name                VARCHAR(255),
  category            VARCHAR(100),
  brand               VARCHAR(100),
  unit_price_usd      DECIMAL(10,2),
  unit_cost_usd       DECIMAL(10,2),
  weight_kg           DECIMAL(6,2),
  is_active           TINYINT(1),
  launch_date         DATE,
  _bronze_batch_id    CHAR(36),
  _silver_loaded_at   DATETIME NOT NULL,
  PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- silver_inventory  (from bb_bronze.bronze_inventory)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS silver_inventory;
CREATE TABLE silver_inventory (
  product_id          VARCHAR(20)  NOT NULL,
  category             VARCHAR(100),
  stock_units          INT,
  reorder_point         INT,
  warehouse_location   VARCHAR(50),
  last_restock_date    DATE,
  supplier_lead_days   INT,
  _bronze_batch_id     CHAR(36),
  _silver_loaded_at    DATETIME NOT NULL,
  PRIMARY KEY (product_id),
  CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)
    REFERENCES silver_products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- silver_supplier_costs  (from bb_bronze.bronze_supplier_costs)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS silver_supplier_costs;
CREATE TABLE silver_supplier_costs (
  product_id               VARCHAR(20) NOT NULL,
  category                 VARCHAR(100),
  supplier_name             VARCHAR(100) NOT NULL,
  supplier_rank             TINYINT,
  unit_cost_usd             DECIMAL(10,2),
  ordering_cost_usd         DECIMAL(10,2),
  annual_holding_cost_usd   DECIMAL(10,2),
  holding_cost_pct          DECIMAL(6,4),
  lead_time_days            INT,
  min_order_qty             INT,
  reliability_score         DECIMAL(4,2),
  is_primary                TINYINT(1),
  _bronze_batch_id          CHAR(36),
  _silver_loaded_at         DATETIME NOT NULL,
  PRIMARY KEY (product_id, supplier_name),
  CONSTRAINT fk_supplier_costs_product FOREIGN KEY (product_id)
    REFERENCES silver_products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- silver_marketing_spend  (from bb_bronze.bronze_marketing_spend)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS silver_marketing_spend;
CREATE TABLE silver_marketing_spend (
  `year_month`            CHAR(7)  NOT NULL,      -- format YYYY-MM
  month_start_date      DATE,                   -- first day of that month
  channel               VARCHAR(50) NOT NULL,
  spend_usd             DECIMAL(14,2),
  impressions           INT,
  clicks                INT,
  ctr                   DECIMAL(8,4),
  actual_orders         INT,
  actual_customers      INT,
  actual_revenue_usd    DECIMAL(14,2),
  roas                  DECIMAL(10,3),
  cac_usd               DECIMAL(10,2),
  cost_per_order_usd    DECIMAL(10,2),
  month_multiplier      DECIMAL(6,2),
  _bronze_batch_id      CHAR(36),
  _silver_loaded_at     DATETIME NOT NULL,
  PRIMARY KEY (`year_month`, channel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- silver_price_history  (from bb_bronze.bronze_price_history)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS silver_price_history;
CREATE TABLE silver_price_history (
  product_id            VARCHAR(20) NOT NULL,
  category              VARCHAR(100),
  `year_month`            CHAR(7) NOT NULL,
  month_start_date      DATE,
  listed_price_usd      DECIMAL(10,2),
  base_price_usd        DECIMAL(10,2),
  competitor_price_usd  DECIMAL(10,2),
  price_index           DECIMAL(6,3),
  is_promotional        TINYINT(1),
  price_elasticity      DECIMAL(6,3),
  units_sold            INT,
  revenue_usd           DECIMAL(12,2),
  margin_pct            DECIMAL(6,4),
  _bronze_batch_id      CHAR(36),
  _silver_loaded_at     DATETIME NOT NULL,
  PRIMARY KEY (product_id, `year_month`),
  CONSTRAINT fk_price_history_product FOREIGN KEY (product_id)
    REFERENCES silver_products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- silver_returns  (from bb_bronze.bronze_returns)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS silver_returns;
CREATE TABLE silver_returns (
  return_id            VARCHAR(20) NOT NULL,
  transaction_id       VARCHAR(20),
  customer_id          VARCHAR(20),
  product_id           VARCHAR(20),
  return_date          DATE,
  reason               VARCHAR(100),
  refund_amount_usd    DECIMAL(10,2),
  restocked            TINYINT(1),
  _bronze_batch_id     CHAR(36),
  _silver_loaded_at    DATETIME NOT NULL,
  PRIMARY KEY (return_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- silver_transactions  (from bb_bronze.bronze_transactions)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS silver_transactions;
CREATE TABLE silver_transactions (
  transaction_id       VARCHAR(20) NOT NULL,
  customer_id          VARCHAR(20),
  product_id           VARCHAR(20),
  txn_date             DATE,
  quantity             INT,
  unit_price_usd       DECIMAL(10,2),
  discount_pct         DECIMAL(6,4),
  revenue_usd          DECIMAL(12,2),
  cost_usd             DECIMAL(12,2),
  profit_usd           DECIMAL(12,2),
  shipping_cost_usd    DECIMAL(10,2),
  channel              VARCHAR(50),
  payment_method       VARCHAR(50),
  status               VARCHAR(30),
  country              VARCHAR(100),
  category             VARCHAR(100),
  _bronze_batch_id     CHAR(36),
  _silver_loaded_at    DATETIME NOT NULL,
  PRIMARY KEY (transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Helpful lookup indexes (not FKs, to keep loads fast/flexible on fact tables)
CREATE INDEX idx_returns_customer   ON silver_returns(customer_id);
CREATE INDEX idx_returns_product    ON silver_returns(product_id);
CREATE INDEX idx_returns_txn        ON silver_returns(transaction_id);
CREATE INDEX idx_txn_customer       ON silver_transactions(customer_id);
CREATE INDEX idx_txn_product        ON silver_transactions(product_id);
CREATE INDEX idx_txn_date           ON silver_transactions(txn_date);
