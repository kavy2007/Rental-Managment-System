-- ============================================
-- 16_triggers.sql
-- All BEFORE UPDATE Triggers (auto-update updated_at)
-- MySQL 8.0 Compatible
-- Must be executed AFTER all CREATE TABLE files
-- ============================================

USE rental_management;

-- Users
CREATE TRIGGER set_timestamp_users
    BEFORE UPDATE ON users
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Companies
CREATE TRIGGER set_timestamp_companies
    BEFORE UPDATE ON companies
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Customers
CREATE TRIGGER set_timestamp_customers
    BEFORE UPDATE ON customers
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Categories
CREATE TRIGGER set_timestamp_categories
    BEFORE UPDATE ON categories
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Products
CREATE TRIGGER set_timestamp_products
    BEFORE UPDATE ON products
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Product Variants
CREATE TRIGGER set_timestamp_product_variants
    BEFORE UPDATE ON product_variants
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Inventory
CREATE TRIGGER set_timestamp_inventory
    BEFORE UPDATE ON inventory
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Rental Orders
CREATE TRIGGER set_timestamp_rental_orders
    BEFORE UPDATE ON rental_orders
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Payments
CREATE TRIGGER set_timestamp_payments
    BEFORE UPDATE ON payments
    FOR EACH ROW SET NEW.updated_at = CURRENT_TIMESTAMP;
