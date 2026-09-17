-- =====================================================
-- Bronze layer schema for MySQL
-- Raw ingestion tables: all source columns kept as VARCHAR
-- (no type casting at Bronze - that belongs to Silver)
-- =====================================================

DROP TABLE IF EXISTS `bronze_customers`;
CREATE TABLE `bronze_customers` (
  `bronze_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` VARCHAR(255),
  `first_name` VARCHAR(255),
  `last_name` VARCHAR(255),
  `country` VARCHAR(255),
  `currency` VARCHAR(255),
  `age` VARCHAR(255),
  `gender` VARCHAR(255),
  `registration_date` VARCHAR(255),
  `is_premium` VARCHAR(255),
  `email_verified` VARCHAR(255),
  `email` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `bronze_inventory`;
CREATE TABLE `bronze_inventory` (
  `bronze_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `product_id` VARCHAR(255),
  `category` VARCHAR(255),
  `stock_units` VARCHAR(255),
  `reorder_point` VARCHAR(255),
  `warehouse_location` VARCHAR(255),
  `last_restock_date` VARCHAR(255),
  `supplier_lead_days` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `bronze_products`;
CREATE TABLE `bronze_products` (
  `bronze_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `product_id` VARCHAR(255),
  `name` VARCHAR(255),
  `category` VARCHAR(255),
  `brand` VARCHAR(255),
  `unit_price_usd` VARCHAR(255),
  `unit_cost_usd` VARCHAR(255),
  `weight_kg` VARCHAR(255),
  `is_active` VARCHAR(255),
  `launch_date` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `bronze_supplier_costs`;
CREATE TABLE `bronze_supplier_costs` (
  `bronze_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `product_id` VARCHAR(255),
  `category` VARCHAR(255),
  `supplier_name` VARCHAR(255),
  `supplier_rank` VARCHAR(255),
  `unit_cost_usd` VARCHAR(255),
  `ordering_cost_usd` VARCHAR(255),
  `annual_holding_cost_usd` VARCHAR(255),
  `holding_cost_pct` VARCHAR(255),
  `lead_time_days` VARCHAR(255),
  `min_order_qty` VARCHAR(255),
  `reliability_score` VARCHAR(255),
  `is_primary` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `bronze_marketing_spend`;
CREATE TABLE `bronze_marketing_spend` (
  `bronze_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `year_month` VARCHAR(255),
  `channel` VARCHAR(255),
  `spend_usd` VARCHAR(255),
  `impressions` VARCHAR(255),
  `clicks` VARCHAR(255),
  `ctr` VARCHAR(255),
  `actual_orders` VARCHAR(255),
  `actual_customers` VARCHAR(255),
  `actual_revenue_usd` VARCHAR(255),
  `roas` VARCHAR(255),
  `cac_usd` VARCHAR(255),
  `cost_per_order_usd` VARCHAR(255),
  `month_multiplier` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `bronze_price_history`;
CREATE TABLE `bronze_price_history` (
  `bronze_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `product_id` VARCHAR(255),
  `category` VARCHAR(255),
  `year_month` VARCHAR(255),
  `listed_price_usd` VARCHAR(255),
  `base_price_usd` VARCHAR(255),
  `competitor_price_usd` VARCHAR(255),
  `price_index` VARCHAR(255),
  `is_promotional` VARCHAR(255),
  `price_elasticity` VARCHAR(255),
  `units_sold` VARCHAR(255),
  `revenue_usd` VARCHAR(255),
  `margin_pct` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `bronze_returns`;
CREATE TABLE `bronze_returns` (
  `bronze_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `return_id` VARCHAR(255),
  `transaction_id` VARCHAR(255),
  `customer_id` VARCHAR(255),
  `product_id` VARCHAR(255),
  `return_date` VARCHAR(255),
  `reason` VARCHAR(255),
  `refund_amount_usd` VARCHAR(255),
  `restocked` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `bronze_transactions`;
CREATE TABLE `bronze_transactions` (
  `bronze_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `transaction_id` VARCHAR(255),
  `customer_id` VARCHAR(255),
  `product_id` VARCHAR(255),
  `date` VARCHAR(255),
  `quantity` VARCHAR(255),
  `unit_price_usd` VARCHAR(255),
  `discount_pct` VARCHAR(255),
  `revenue_usd` VARCHAR(255),
  `cost_usd` VARCHAR(255),
  `profit_usd` VARCHAR(255),
  `shipping_cost_usd` VARCHAR(255),
  `channel` VARCHAR(255),
  `payment_method` VARCHAR(255),
  `status` VARCHAR(255),
  `country` VARCHAR(255),
  `category` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
