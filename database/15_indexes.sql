-- ============================================
-- 15_indexes.sql
-- All Database Indexes
-- MySQL 8.0 Compatible
-- Must be executed AFTER all CREATE TABLE files
-- ============================================

USE rental_management;

-- Users
CREATE INDEX idx_users_email ON users(email);

-- Customers
CREATE INDEX idx_customers_email ON customers(email);

-- Orders
CREATE INDEX idx_orders_customer_id ON rental_orders(customer_id);
CREATE INDEX idx_orders_status ON rental_orders(status);

-- Products
CREATE INDEX idx_products_company_id ON products(company_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_name ON products(name);

-- Product Variants
CREATE INDEX idx_variants_sku ON product_variants(sku);

-- Inventory
CREATE INDEX idx_inventory_warehouse_id ON inventory(warehouse_id);

-- Invoices
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);

-- Order Items
CREATE INDEX idx_order_items_dates ON rental_order_items(start_date, end_date);
