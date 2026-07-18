-- ============================================
-- 06_inventory.sql
-- Warehouses, Inventory & Stock Management
-- MySQL 8.0 Compatible
-- Depends on: 02_users.sql, 03_company.sql, 05_products.sql
-- ============================================

USE rental_management;

CREATE TABLE warehouses (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    company_id CHAR(36),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE warehouse_locations (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    warehouse_id CHAR(36),
    aisle VARCHAR(50),
    rack VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE inventory (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    variant_id CHAR(36),
    warehouse_id CHAR(36),
    quantity_total INT DEFAULT 0,
    quantity_available INT DEFAULT 0 CHECK (quantity_available >= 0),
    quantity_reserved INT DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_rented INT DEFAULT 0 CHECK (quantity_rented >= 0),
    quantity_damaged INT DEFAULT 0 CHECK (quantity_damaged >= 0),
    quantity_under_maintenance INT DEFAULT 0 CHECK (quantity_under_maintenance >= 0),
    quantity_lost INT DEFAULT 0 CHECK (quantity_lost >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    UNIQUE (variant_id, warehouse_id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE stock_movements (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    variant_id CHAR(36),
    from_warehouse_id CHAR(36),
    to_warehouse_id CHAR(36),
    quantity INT NOT NULL,
    reference_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE inventory_adjustments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    inventory_id CHAR(36),
    quantity_change INT NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE maintenance_records (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    variant_id CHAR(36),
    description TEXT,
    cost DECIMAL(12,2) DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
