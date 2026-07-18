
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TYPE order_status_enum AS ENUM ('Draft', 'Quotation', 'Quotation Sent', 'Confirmed', 'Invoice Generated', 'Paid', 'Pickup Ready', 'Picked Up', 'Active Rental', 'Extended', 'Return Requested', 'Returned', 'Completed', 'Cancelled');
CREATE TYPE payment_status_enum AS ENUM ('Pending', 'Processing', 'Paid', 'Failed', 'Refunded', 'Partially Refunded', 'Cancelled');
CREATE TYPE return_status_enum AS ENUM ('Pending', 'Returned', 'Late', 'Damaged', 'Repair Required', 'Completed');
CREATE TYPE inventory_status_enum AS ENUM ('Available', 'Reserved', 'Rented', 'Maintenance', 'Damaged', 'Lost');
CREATE TYPE product_status_enum AS ENUM ('Active', 'Draft', 'Archived', 'Discontinued');
CREATE TYPE delivery_status_enum AS ENUM ('Pending', 'Scheduled', 'In Transit', 'Delivered', 'Failed', 'Returned');


CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID
);
CREATE TRIGGER set_timestamp_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    module VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE role_permissions (
    role_id UUID REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE,
    permission_id UUID REFERENCES permissions(id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_roles (
    user_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    role_id UUID REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE user_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    address_line TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE password_resets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE email_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE otp_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    otp VARCHAR(6) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    registration_number VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE TRIGGER set_timestamp_companies BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TABLE company_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID UNIQUE REFERENCES companies(id) ON UPDATE CASCADE ON DELETE CASCADE,
    currency VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(100) DEFAULT 'UTC',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE gst_details (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID UNIQUE REFERENCES companies(id) ON UPDATE CASCADE ON DELETE CASCADE,
    gstin VARCHAR(15) UNIQUE NOT NULL,
    legal_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE invoice_configurations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID UNIQUE REFERENCES companies(id) ON UPDATE CASCADE ON DELETE CASCADE,
    prefix VARCHAR(20),
    next_number INT DEFAULT 1,
    terms TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE company_rental_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID UNIQUE REFERENCES companies(id) ON UPDATE CASCADE ON DELETE CASCADE,
    default_grace_period INT DEFAULT 0,
    late_fee_percentage DECIMAL(5,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE TRIGGER set_timestamp_customers BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TABLE customer_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    address_line TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    zip VARCHAR(50) NOT NULL,
    is_billing BOOLEAN DEFAULT FALSE,
    is_shipping BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE customer_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE customer_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    doc_type VARCHAR(100) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE customer_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    note TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    slug VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE TRIGGER set_timestamp_categories BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TABLE brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    logo_url VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE manufacturers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    category_id UUID REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    brand_id UUID REFERENCES brands(id) ON UPDATE CASCADE ON DELETE SET NULL,
    manufacturer_id UUID REFERENCES manufacturers(id) ON UPDATE CASCADE ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status product_status_enum DEFAULT 'Draft',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE TRIGGER set_timestamp_products BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
    sku VARCHAR(100) UNIQUE NOT NULL,
    base_price DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    replacement_value DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE TRIGGER set_timestamp_product_variants BEFORE UPDATE ON product_variants FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TABLE attributes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE attribute_values (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attribute_id UUID REFERENCES attributes(id) ON UPDATE CASCADE ON DELETE CASCADE,
    value VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE variant_combinations (
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE CASCADE,
    attribute_value_id UUID REFERENCES attribute_values(id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (variant_id, attribute_value_id)
);

CREATE TABLE product_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID UNIQUE REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE CASCADE,
    is_available_online BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE product_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);



CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON UPDATE CASCADE ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE warehouse_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE CASCADE,
    aisle VARCHAR(50),
    rack VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    warehouse_id UUID REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity_total INT DEFAULT 0,
    quantity_available INT DEFAULT 0 CHECK (quantity_available >= 0),
    quantity_reserved INT DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_rented INT DEFAULT 0 CHECK (quantity_rented >= 0),
    quantity_damaged INT DEFAULT 0 CHECK (quantity_damaged >= 0),
    quantity_under_maintenance INT DEFAULT 0 CHECK (quantity_under_maintenance >= 0),
    quantity_lost INT DEFAULT 0 CHECK (quantity_lost >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    UNIQUE (variant_id, warehouse_id)
);
CREATE TRIGGER set_timestamp_inventory BEFORE UPDATE ON inventory FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    from_warehouse_id UUID REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    to_warehouse_id UUID REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity INT NOT NULL,
    reference_type VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE inventory_adjustments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_id UUID REFERENCES inventory(id) ON UPDATE CASCADE ON DELETE CASCADE,
    quantity_change INT NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE maintenance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE CASCADE,
    description TEXT,
    cost DECIMAL(12,2) DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE wishlists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID UNIQUE REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE wishlist_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wishlist_id UUID REFERENCES wishlists(id) ON UPDATE CASCADE ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (wishlist_id, variant_id)
);

CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID UNIQUE REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    session_id VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID REFERENCES carts(id) ON UPDATE CASCADE ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE CASCADE,
    quantity INT DEFAULT 1,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type VARCHAR(50) NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL,
    valid_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE coupon_usages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id UUID REFERENCES coupons(id) ON UPDATE CASCADE ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    order_id UUID, -- Will link to rental_orders below
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE rental_periods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_durations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    period_id UUID REFERENCES rental_periods(id) ON UPDATE CASCADE ON DELETE CASCADE,
    duration_value INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE pricing_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    formula_type VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE pricelists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE pricelist_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pricelist_id UUID REFERENCES pricelists(id) ON UPDATE CASCADE ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE CASCADE,
    rental_period_id UUID REFERENCES rental_periods(id) ON UPDATE CASCADE ON DELETE CASCADE,
    price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE quotation_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    header_text TEXT,
    footer_text TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    template_id UUID REFERENCES quotation_templates(id) ON UPDATE CASCADE ON DELETE SET NULL,
    valid_until TIMESTAMPTZ,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE quotation_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quotation_id UUID REFERENCES quotations(id) ON UPDATE CASCADE ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    status order_status_enum DEFAULT 'Draft',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    security_deposit DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE TRIGGER set_timestamp_rental_orders BEFORE UPDATE ON rental_orders FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
ALTER TABLE coupon_usages ADD CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES rental_orders(id) ON DELETE SET NULL;

CREATE TABLE rental_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL CHECK (start_date <= end_date),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_schedule (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id UUID REFERENCES rental_order_items(id) ON UPDATE CASCADE ON DELETE CASCADE,
    expected_pickup TIMESTAMPTZ,
    expected_return TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    status order_status_enum NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_extensions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    new_end_date TIMESTAMPTZ NOT NULL,
    additional_cost DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE delivery_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    address_id UUID REFERENCES customer_addresses(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE shipping_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    base_cost DECIMAL(12,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE delivery_zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    zip_codes TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE delivery_charges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_id UUID REFERENCES delivery_zones(id) ON UPDATE CASCADE ON DELETE CASCADE,
    method_id UUID REFERENCES shipping_methods(id) ON UPDATE CASCADE ON DELETE CASCADE,
    cost DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE pickup_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    scheduled_time TIMESTAMPTZ,
    status delivery_status_enum DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE return_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    scheduled_time TIMESTAMPTZ,
    status delivery_status_enum DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    amount DECIMAL(12,2) NOT NULL,
    status payment_status_enum DEFAULT 'Pending',
    method VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE TRIGGER set_timestamp_payments BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID REFERENCES payments(id) ON UPDATE CASCADE ON DELETE CASCADE,
    gateway VARCHAR(100),
    transaction_reference VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE razorpay_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID REFERENCES payments(id) ON UPDATE CASCADE ON DELETE CASCADE,
    rzp_order_id VARCHAR(255),
    rzp_payment_id VARCHAR(255),
    rzp_signature VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    total_due DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoices(id) ON UPDATE CASCADE ON DELETE CASCADE,
    description VARCHAR(255),
    amount DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE security_deposits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    amount_collected DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE deposit_refunds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deposit_id UUID REFERENCES security_deposits(id) ON UPDATE CASCADE ON DELETE CASCADE,
    amount_refunded DECIMAL(12,2) NOT NULL,
    deductions DECIMAL(12,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE refunds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID REFERENCES payments(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    amount DECIMAL(12,2) NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE late_penalties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    days_late INT NOT NULL,
    penalty_amount DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES rental_orders(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    status return_status_enum DEFAULT 'Pending',
    actual_return_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE return_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID REFERENCES returns(id) ON UPDATE CASCADE ON DELETE CASCADE,
    order_item_id UUID REFERENCES rental_order_items(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity_returned INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE inspection_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID REFERENCES returns(id) ON UPDATE CASCADE ON DELETE CASCADE,
    inspector_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    condition_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE damage_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inspection_id UUID REFERENCES inspection_reports(id) ON UPDATE CASCADE ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    damage_description TEXT,
    repair_cost_estimate DECIMAL(12,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE missing_accessories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inspection_id UUID REFERENCES inspection_reports(id) ON UPDATE CASCADE ON DELETE CASCADE,
    accessory_name VARCHAR(255) NOT NULL,
    charge_amount DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE repair_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    damage_id UUID REFERENCES damage_reports(id) ON UPDATE CASCADE ON DELETE CASCADE,
    vendor_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE sales_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_date DATE NOT NULL,
    total_sales DECIMAL(15,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE rental_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_date DATE NOT NULL,
    active_rentals INT DEFAULT 0,
    completed_rentals INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE inventory_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_date DATE NOT NULL,
    total_items INT DEFAULT 0,
    items_rented INT DEFAULT 0,
    items_maintenance INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE customer_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    lifetime_value DECIMAL(15,2) DEFAULT 0.0,
    total_orders INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE report_exports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    report_type VARCHAR(100) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON UPDATE CASCADE ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trigger_event VARCHAR(100) NOT NULL,
    subject_template VARCHAR(255) NOT NULL,
    body_template TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE email_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    action VARCHAR(255) NOT NULL,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);


CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_orders_customer_id ON rental_orders(customer_id);
CREATE INDEX idx_products_company_id ON products(company_id);
CREATE INDEX idx_variants_sku ON product_variants(sku);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_inventory_warehouse_id ON inventory(warehouse_id);
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);
CREATE INDEX idx_orders_status ON rental_orders(status);
CREATE INDEX idx_order_items_dates ON rental_order_items(start_date, end_date);
CREATE INDEX idx_products_name ON products(name);
