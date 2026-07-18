-- ============================================
-- 09_orders.sql
-- Rental Orders, Items, Schedule & Extensions
-- MySQL 8.0 Compatible
-- Depends on: 02_users.sql, 04_customers.sql, 05_products.sql, 07_cart.sql
-- ============================================

USE rental_management;

CREATE TABLE rental_orders (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    customer_id CHAR(36),
    status ENUM('Draft', 'Quotation', 'Quotation Sent', 'Confirmed', 'Invoice Generated', 'Paid', 'Pickup Ready', 'Picked Up', 'Active Rental', 'Extended', 'Return Requested', 'Returned', 'Completed', 'Cancelled') DEFAULT 'Draft',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    security_deposit DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Deferred FK: Link coupon_usages.order_id to rental_orders
ALTER TABLE coupon_usages ADD CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES rental_orders(id) ON DELETE SET NULL;

CREATE TABLE rental_order_items (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    order_id CHAR(36),
    variant_id CHAR(36),
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL CHECK (start_date <= end_date),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (order_id) REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_schedule (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    order_item_id CHAR(36),
    expected_pickup TIMESTAMP,
    expected_return TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (order_item_id) REFERENCES rental_order_items(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_status_history (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    order_id CHAR(36),
    status ENUM('Draft', 'Quotation', 'Quotation Sent', 'Confirmed', 'Invoice Generated', 'Paid', 'Pickup Ready', 'Picked Up', 'Active Rental', 'Extended', 'Return Requested', 'Returned', 'Completed', 'Cancelled') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (order_id) REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_extensions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    order_id CHAR(36),
    new_end_date TIMESTAMP NOT NULL,
    additional_cost DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (order_id) REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
