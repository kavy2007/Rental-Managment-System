-- ============================================
-- 12_returns.sql
-- Returns, Inspections, Damage & Repairs
-- MySQL 8.0 Compatible
-- Depends on: 02_users.sql, 05_products.sql, 09_orders.sql
-- ============================================

USE rental_management;

CREATE TABLE returns (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    order_id CHAR(36),
    status ENUM('Pending', 'Returned', 'Late', 'Damaged', 'Repair Required', 'Completed') DEFAULT 'Pending',
    actual_return_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (order_id) REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE return_items (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    return_id CHAR(36),
    order_item_id CHAR(36),
    quantity_returned INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (return_id) REFERENCES returns(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES rental_order_items(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE inspection_reports (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    return_id CHAR(36),
    inspector_id CHAR(36),
    condition_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (return_id) REFERENCES returns(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (inspector_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE damage_reports (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    inspection_id CHAR(36),
    variant_id CHAR(36),
    damage_description TEXT,
    repair_cost_estimate DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (inspection_id) REFERENCES inspection_reports(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE missing_accessories (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    inspection_id CHAR(36),
    accessory_name VARCHAR(255) NOT NULL,
    charge_amount DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (inspection_id) REFERENCES inspection_reports(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE repair_requests (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    damage_id CHAR(36),
    vendor_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (damage_id) REFERENCES damage_reports(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
