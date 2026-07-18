# Rental Management System — Database Schema

## Overview

Enterprise-grade Rental Management System database schema, fully compatible with **MySQL 8.0+** and **MySQL Workbench**.

Originally converted from PostgreSQL to MySQL with all tables, foreign keys, constraints, indexes, and triggers preserved.

---

## Project Structure

```
database/
│
├── 00_database.sql          # Database creation & charset config
├── 01_enums.sql             # ENUM type reference documentation
├── 02_users.sql             # Users, roles, permissions, authentication
├── 03_company.sql           # Companies, settings, GST, invoice config
├── 04_customers.sql         # Customers, addresses, contacts, documents
├── 05_products.sql          # Categories, brands, products, variants, attributes
├── 06_inventory.sql         # Warehouses, inventory, stock movements
├── 07_cart.sql              # Wishlists, carts, coupons
├── 08_pricing.sql           # Rental periods, pricelists, quotations
├── 09_orders.sql            # Rental orders, items, schedule, extensions
├── 10_delivery.sql          # Delivery, shipping, pickup/return schedules
├── 11_payments.sql          # Payments, invoices, deposits, refunds
├── 12_returns.sql           # Returns, inspections, damage, repairs
├── 13_reports.sql           # Sales, rental, inventory, customer reports
├── 14_notifications.sql     # Notifications, email/audit/activity logs
├── 15_indexes.sql           # All performance indexes
├── 16_triggers.sql          # All BEFORE UPDATE triggers
└── README.md                # This file
```

---

## Execution Order

Files **must** be executed in this exact order to satisfy foreign key dependencies:

| Order | File                   | Description                                    |
|-------|------------------------|------------------------------------------------|
| 1     | `00_database.sql`      | Creates the database                           |
| 2     | `01_enums.sql`         | ENUM documentation (no SQL to execute)         |
| 3     | `02_users.sql`         | Core users & auth tables                       |
| 4     | `03_company.sql`       | Company & config tables (depends on users)     |
| 5     | `04_customers.sql`     | Customer tables (depends on users, companies)  |
| 6     | `05_products.sql`      | Product catalog (depends on users, companies, customers) |
| 7     | `06_inventory.sql`     | Inventory (depends on users, companies, products) |
| 8     | `07_cart.sql`          | Cart & coupons (depends on users, customers, products) |
| 9     | `08_pricing.sql`       | Pricing & quotations (depends on users, customers, products) |
| 10    | `09_orders.sql`        | Rental orders (depends on users, customers, products, cart) |
| 11    | `10_delivery.sql`      | Delivery & shipping (depends on users, customers, orders) |
| 12    | `11_payments.sql`      | Payments & invoices (depends on users, orders)  |
| 13    | `12_returns.sql`       | Returns & inspections (depends on users, products, orders) |
| 14    | `13_reports.sql`       | Reports (depends on users, customers)           |
| 15    | `14_notifications.sql` | Notifications & logs (depends on users, customers) |
| 16    | `15_indexes.sql`       | All indexes (run after all tables exist)        |
| 17    | `16_triggers.sql`      | All triggers (run after all tables exist)       |

---

## Dependencies Between Files

```
02_users.sql ──────────────────────────────────────────────────┐
    │                                                          │
    ├── 03_company.sql                                         │
    │       │                                                  │
    │       ├── 04_customers.sql                               │
    │       │       │                                          │
    │       │       ├── 05_products.sql                        │
    │       │       │       │                                  │
    │       │       │       ├── 06_inventory.sql               │
    │       │       │       ├── 07_cart.sql                    │
    │       │       │       └── 08_pricing.sql                 │
    │       │       │                                          │
    │       │       └── 09_orders.sql (+ ALTER TABLE from 07)  │
    │       │               │                                  │
    │       │               ├── 10_delivery.sql                │
    │       │               ├── 11_payments.sql                │
    │       │               └── 12_returns.sql                 │
    │       │                                                  │
    │       ├── 13_reports.sql                                 │
    │       └── 14_notifications.sql                           │
    │                                                          │
    ├── 15_indexes.sql (after all tables)                      │
    └── 16_triggers.sql (after all tables) ────────────────────┘
```

---

## How to Execute in MySQL Workbench

### Option 1: Execute files individually

1. Open MySQL Workbench and connect to your server.
2. Open each `.sql` file in order (File → Open SQL Script).
3. Execute each file with the ⚡ button (or `Ctrl+Shift+Enter`).

### Option 2: Execute via MySQL command line

```bash
mysql -u root -p < database/00_database.sql
mysql -u root -p rental_management < database/02_users.sql
mysql -u root -p rental_management < database/03_company.sql
mysql -u root -p rental_management < database/04_customers.sql
mysql -u root -p rental_management < database/05_products.sql
mysql -u root -p rental_management < database/06_inventory.sql
mysql -u root -p rental_management < database/07_cart.sql
mysql -u root -p rental_management < database/08_pricing.sql
mysql -u root -p rental_management < database/09_orders.sql
mysql -u root -p rental_management < database/10_delivery.sql
mysql -u root -p rental_management < database/11_payments.sql
mysql -u root -p rental_management < database/12_returns.sql
mysql -u root -p rental_management < database/13_reports.sql
mysql -u root -p rental_management < database/14_notifications.sql
mysql -u root -p rental_management < database/15_indexes.sql
mysql -u root -p rental_management < database/16_triggers.sql
```

---

## Schema Statistics

| Metric              | Count |
|----------------------|-------|
| Total Tables         | 62    |
| Total Foreign Keys   | 176   |
| Total Indexes        | 11    |
| Total Triggers       | 9     |

---

## PostgreSQL → MySQL Conversion Notes

| PostgreSQL Feature         | MySQL 8.0 Equivalent          |
|----------------------------|-------------------------------|
| `CREATE EXTENSION uuid-ossp` | Removed (MySQL has native `UUID()`) |
| `UUID` type                | `CHAR(36)` with `DEFAULT (UUID())` |
| `uuid_generate_v4()`       | `UUID()`                      |
| `TIMESTAMPTZ`              | `TIMESTAMP`                   |
| `JSONB`                    | `JSON`                        |
| `TEXT[]`                   | `JSON`                        |
| `INET`                     | `VARCHAR(45)`                 |
| `CREATE TYPE ... AS ENUM`  | Inline `ENUM(...)` columns    |
| `NOW()`                    | `CURRENT_TIMESTAMP`           |
| PL/pgSQL trigger function  | MySQL `BEFORE UPDATE` trigger |
| `SERIAL`                   | `AUTO_INCREMENT` (not used)   |

---

## Important Notes

- **Circular FK dependency resolved**: `coupon_usages.order_id` references `rental_orders`, but `coupon_usages` is created before `rental_orders`. The FK is added via `ALTER TABLE` in `09_orders.sql`.
- **`returns` is a MySQL reserved word** but works as a table name when not conflicting with context. If issues arise, wrap with backticks: `` `returns` ``.
- All `deleted_at` columns support **soft delete** patterns.
- All tables include `created_by` and `updated_by` **audit columns** referencing `users(id)`.
