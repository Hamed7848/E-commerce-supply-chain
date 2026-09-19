# Data Dictionary

Source: 8 raw CSV files representing an e-commerce business (customers, catalog,
inventory, suppliers, marketing, pricing, sales, and returns). All monetary
values are in USD unless noted otherwise.

---

## 1. `customers.csv`
One row per customer.

| Column | Type | Description |
|---|---|---|
| customer_id | string | Unique customer identifier (PK) |
| first_name | string | Customer's first name |
| last_name | string | Customer's last name |
| country | string | Country of residence |
| currency | string (3) | Customer's local currency code |
| age | integer | Customer age |
| gender | string | Customer gender |
| registration_date | date | Date the customer signed up |
| is_premium | boolean | Whether the customer holds a premium/loyalty membership |
| email_verified | boolean | Whether the customer's email has been verified |
| email | string | Customer email address |

## 2. `products.csv`
One row per product (catalog).

| Column | Type | Description |
|---|---|---|
| product_id | string | Unique product identifier (PK) |
| name | string | Product name |
| category | string | Product category |
| brand | string | Product brand |
| unit_price_usd | decimal | Current list (selling) price |
| unit_cost_usd | decimal | Current unit cost to the business |
| weight_kg | decimal | Product weight in kilograms |
| is_active | boolean | Whether the product is currently sold |
| launch_date | date | Date the product was introduced |

## 3. `inventory.csv`
One row per product (current stock snapshot).

| Column | Type | Description |
|---|---|---|
| product_id | string | Product identifier (FK -> products) |
| category | string | Product category |
| stock_units | integer | Units currently in stock |
| reorder_point | integer | Stock level that should trigger a reorder |
| warehouse_location | string | Warehouse/location code |
| last_restock_date | date | Date of the most recent restock |
| supplier_lead_days | integer | Typical lead time (days) to restock |

## 4. `supplier_costs.csv`
One row per (product, supplier) pair — a product can have multiple suppliers.

| Column | Type | Description |
|---|---|---|
| product_id | string | Product identifier (FK -> products) |
| category | string | Product category |
| supplier_name | string | Supplier name |
| supplier_rank | integer | Supplier's preference rank for this product |
| unit_cost_usd | decimal | Cost per unit from this supplier |
| ordering_cost_usd | decimal | Fixed cost per order placed |
| annual_holding_cost_usd | decimal | Estimated annual cost of holding stock |
| holding_cost_pct | decimal | Holding cost as a percentage of unit cost |
| lead_time_days | integer | Delivery lead time from this supplier |
| min_order_qty | integer | Minimum order quantity |
| reliability_score | decimal | Supplier reliability score |
| is_primary | boolean | Whether this is the primary supplier for the product |

## 5. `marketing_spend.csv`
One row per (month, channel) — monthly marketing performance.

| Column | Type | Description |
|---|---|---|
| year_month | string ('YYYY-MM') | Calendar month |
| channel | string | Marketing channel (e.g. paid_search, email, social_media) |
| spend_usd | decimal | Amount spent on this channel that month |
| impressions | integer | Ad impressions served |
| clicks | integer | Ad clicks recorded |
| ctr | decimal | Click-through rate |
| actual_orders | integer | Orders attributed to the channel (as reported by the ad platform) |
| actual_customers | integer | Distinct customers attributed to the channel |
| actual_revenue_usd | decimal | Revenue attributed to the channel (as reported) |
| roas | decimal | Return on ad spend |
| cac_usd | decimal | Customer acquisition cost |
| cost_per_order_usd | decimal | Cost per order |
| month_multiplier | decimal | Seasonal multiplier applied for that month |

## 6. `price_history.csv`
One row per (product, month) — monthly pricing and sales performance.

| Column | Type | Description |
|---|---|---|
| product_id | string | Product identifier (FK -> products) |
| category | string | Product category |
| year_month | string ('YYYY-MM') | Calendar month |
| listed_price_usd | decimal | Listed selling price that month |
| base_price_usd | decimal | Baseline (non-promotional) price |
| competitor_price_usd | decimal | Comparable competitor price |
| price_index | decimal | Price relative to competitor (index) |
| is_promotional | boolean | Whether the price was promotional that month |
| price_elasticity | decimal | Estimated price elasticity of demand |
| units_sold | integer | Units sold that month |
| revenue_usd | decimal | Revenue generated that month |
| margin_pct | decimal | Gross margin percentage |

## 7. `transactions.csv`
One row per sales transaction (fact table — largest dataset).

| Column | Type | Description |
|---|---|---|
| transaction_id | string | Unique transaction identifier (PK) |
| customer_id | string | Customer identifier (FK -> customers) |
| product_id | string | Product identifier (FK -> products) |
| date | date | Transaction date |
| quantity | integer | Units purchased |
| unit_price_usd | decimal | Price per unit at time of sale |
| discount_pct | decimal | Discount applied |
| revenue_usd | decimal | Total revenue for the line |
| cost_usd | decimal | Total cost for the line |
| profit_usd | decimal | Total profit for the line |
| shipping_cost_usd | decimal | Shipping cost for the line |
| channel | string | Acquisition/sales channel |
| payment_method | string | Payment method used |
| status | string | `completed`, `cancelled`, or `refunded` |
| country | string | Customer's country at time of sale |
| category | string | Product category |

## 8. `returns.csv`
One row per product return (linked to a transaction).

| Column | Type | Description |
|---|---|---|
| return_id | string | Unique return identifier (PK) |
| transaction_id | string | Related transaction (FK -> transactions) |
| customer_id | string | Customer identifier (FK -> customers) |
| product_id | string | Product identifier (FK -> products) |
| return_date | date | Date the return was processed |
| reason | string | Return reason (e.g. defective, wrong_item, changed_mind) |
| refund_amount_usd | decimal | Amount refunded |
| restocked | boolean | Whether the returned item was restocked |

---

## Relationships

```
customers ──< transactions >── products ──< inventory (1:1)
                  │                │
                  │                └──< supplier_costs (1:many)
                  │                └──< price_history (1:many, by month)
                  └──< returns >───┘
marketing_spend (independent, grain = month + channel)
```
