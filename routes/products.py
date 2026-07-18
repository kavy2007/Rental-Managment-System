from flask import Blueprint, request, jsonify
from db import execute_query
import uuid

products_bp = Blueprint('products', __name__)

@products_bp.route('/', methods=['GET'])
def get_products():
    """Get all products for the catalog"""
    try:
        # A complex query to fetch everything in one go for the frontend mock structure
        query = """
            SELECT 
                p.id as id,
                p.name as name,
                p.description as description,
                p.status as status,
                c.name as category,
                'Generic' as brand,
                (SELECT image_url FROM product_images WHERE product_id = p.id LIMIT 1) as image,
                (SELECT base_price FROM product_variants WHERE product_id = p.id LIMIT 1) as pricePerDay,
                (SELECT weekly_price FROM product_variants WHERE product_id = p.id LIMIT 1) as weeklyPrice,
                (SELECT monthly_price FROM product_variants WHERE product_id = p.id LIMIT 1) as monthlyPrice,
                (SELECT replacement_value FROM product_variants WHERE product_id = p.id LIMIT 1) as securityDeposit,
                (SELECT SUM(quantity_available) FROM inventory i JOIN product_variants pv ON i.variant_id = pv.id WHERE pv.product_id = p.id) as stock
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
        """
        products_data = execute_query(query, fetchall=True)
        
        # Format for frontend
        formatted_products = []
        for p in products_data:
            formatted_products.append({
                "id": p["id"],
                "name": p["name"],
                "brand": p["brand"] or "Generic",
                "category": p["category"] or "Uncategorized",
                "image": p["image"] or "https://via.placeholder.com/150",
                "pricePerDay": float(p["pricePerDay"] or 0),
                "weeklyPrice": float(p["weeklyPrice"] or 0),
                "monthlyPrice": float(p["monthlyPrice"] or 0),
                "securityDeposit": float(p["securityDeposit"] or 0),
                "status": "Available" if (p["stock"] and p["stock"] > 0 and p["status"] == "Active") else "Unavailable",
                "stock": int(p["stock"] or 0),
                "description": p["description"] or ""
            })
            
        return jsonify(formatted_products), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@products_bp.route('/<product_id>', methods=['GET'])
def get_product(product_id):
    """Get a single product"""
    try:
        query = """
            SELECT 
                p.id as id,
                p.name as name,
                p.description as description,
                p.status as status,
                c.name as category,
                'Generic' as brand,
                (SELECT image_url FROM product_images WHERE product_id = p.id LIMIT 1) as image,
                (SELECT base_price FROM product_variants WHERE product_id = p.id LIMIT 1) as pricePerDay,
                (SELECT weekly_price FROM product_variants WHERE product_id = p.id LIMIT 1) as weeklyPrice,
                (SELECT monthly_price FROM product_variants WHERE product_id = p.id LIMIT 1) as monthlyPrice,
                (SELECT replacement_value FROM product_variants WHERE product_id = p.id LIMIT 1) as securityDeposit,
                (SELECT SUM(quantity_available) FROM inventory i JOIN product_variants pv ON i.variant_id = pv.id WHERE pv.product_id = p.id) as stock,
                (SELECT id FROM product_variants WHERE product_id = p.id LIMIT 1) as variant_id
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            WHERE p.id = %s
        """
        p = execute_query(query, (product_id,), fetch=True)
        
        if not p:
            return jsonify({"error": "Product not found"}), 404
            
        formatted_product = {
            "id": p["id"],
            "name": p["name"],
            "brand": p["brand"] or "Generic",
            "category": p["category"] or "Uncategorized",
            "image": p["image"] or "https://via.placeholder.com/150",
            "pricePerDay": float(p["pricePerDay"] or 0),
            "weeklyPrice": float(p["weeklyPrice"] or 0),
            "monthlyPrice": float(p["monthlyPrice"] or 0),
            "securityDeposit": float(p["securityDeposit"] or 0),
            "status": "Available" if (p["stock"] and p["stock"] > 0) else "Unavailable",
            "stock": int(p["stock"] or 0),
            "description": p["description"] or "",
            "variant_id": p["variant_id"]
        }
            
        return jsonify(formatted_product), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@products_bp.route('/', methods=['POST'])
def add_product():
    """Add a new product"""
    data = request.json
    try:
        product_id = str(uuid.uuid4())
        variant_id = str(uuid.uuid4())
        # Find or create category
        category_name = data.get('category', 'Uncategorized')
        category = execute_query("SELECT id FROM categories WHERE name = %s LIMIT 1", (category_name,), fetch=True)
        if category:
            category_id = category['id']
        else:
            category_id = str(uuid.uuid4())
            execute_query(
                "INSERT INTO categories (id, name, slug) VALUES (%s, %s, %s)",
                (category_id, category_name, category_name.lower().replace(' ', '-')),
                commit=True
            )
            
        # 1. Insert Product
        execute_query(
            "INSERT INTO products (id, name, description, status, category_id) VALUES (%s, %s, %s, 'Active', %s)",
            (product_id, data.get('name'), data.get('description'), category_id),
            commit=True
        )
        
        # 2. Insert Variant
        execute_query(
            "INSERT INTO product_variants (id, product_id, sku, base_price, weekly_price, monthly_price, replacement_value) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (variant_id, product_id, f"SKU-{product_id[:8]}", data.get('pricePerDay', 0), data.get('weeklyPrice', 0), data.get('monthlyPrice', 0), data.get('securityDeposit', 0)),
            commit=True
        )
        
        # 3. Add to inventory
        if 'stock' in data:
            stock = int(data.get('stock', 0))
            warehouse = execute_query("SELECT id FROM warehouses LIMIT 1", fetch=True)
            if not warehouse:
                warehouse_id = str(uuid.uuid4())
                execute_query("INSERT INTO warehouses (id, name) VALUES (%s, 'Main Warehouse')", (warehouse_id,), commit=True)
            else:
                warehouse_id = warehouse['id']
            execute_query(
                "INSERT INTO inventory (id, variant_id, warehouse_id, quantity_total, quantity_available) VALUES (%s, %s, %s, %s, %s)",
                (str(uuid.uuid4()), variant_id, warehouse_id, stock, stock),
                commit=True
            )
            
        return jsonify({"message": "Product created successfully", "id": product_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@products_bp.route('/<product_id>', methods=['DELETE'])
def delete_product(product_id):
    """Delete a product by ID"""
    try:
        # Note: In a real DB with foreign keys, you may need to delete variants/inventory first,
        # or rely on ON DELETE CASCADE. Assuming cascade is set up based on the schema.
        execute_query("DELETE FROM products WHERE id = %s", (product_id,), commit=True)
        return jsonify({"success": True, "message": "Product deleted successfully"}), 200
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 400

@products_bp.route('/<product_id>', methods=['PUT'])
def update_product(product_id):
    """Update a product by ID"""
    data = request.json
    try:
        # Check if product exists
        existing = execute_query("SELECT id FROM products WHERE id = %s", (product_id,), fetch=True)
        if not existing:
            return jsonify({"success": False, "message": "Product not found"}), 404
            
        # Find or create category
        category_name = data.get('category', 'Uncategorized')
        category = execute_query("SELECT id FROM categories WHERE name = %s LIMIT 1", (category_name,), fetch=True)
        if category:
            category_id = category['id']
        else:
            category_id = str(uuid.uuid4())
            execute_query(
                "INSERT INTO categories (id, name, slug) VALUES (%s, %s, %s)",
                (category_id, category_name, category_name.lower().replace(' ', '-')),
                commit=True
            )
            
        # Update product
        execute_query(
            "UPDATE products SET name = %s, description = %s, category_id = %s WHERE id = %s",
            (data.get('name'), data.get('description', ''), category_id, product_id),
            commit=True
        )
        
        # Update variant (assuming one variant per product for now)
        variant = execute_query("SELECT id FROM product_variants WHERE product_id = %s LIMIT 1", (product_id,), fetch=True)
        if variant:
            execute_query(
                "UPDATE product_variants SET base_price = %s, weekly_price = %s, monthly_price = %s, replacement_value = %s WHERE product_id = %s",
                (data.get('pricePerDay', 0), data.get('weeklyPrice', 0), data.get('monthlyPrice', 0), data.get('securityDeposit', 0), product_id),
                commit=True
            )
            
            if 'stock' in data:
                stock = int(data.get('stock', 0))
                warehouse = execute_query("SELECT id FROM warehouses LIMIT 1", fetch=True)
                if not warehouse:
                    warehouse_id = str(uuid.uuid4())
                    execute_query("INSERT INTO warehouses (id, name) VALUES (%s, 'Main Warehouse')", (warehouse_id,), commit=True)
                else:
                    warehouse_id = warehouse['id']
                
                inv = execute_query("SELECT id FROM inventory WHERE variant_id = %s AND warehouse_id = %s", (variant['id'], warehouse_id), fetch=True)
                if inv:
                    execute_query("UPDATE inventory SET quantity_total = %s, quantity_available = %s WHERE id = %s", (stock, stock, inv['id']), commit=True)
                else:
                    execute_query(
                        "INSERT INTO inventory (id, variant_id, warehouse_id, quantity_total, quantity_available) VALUES (%s, %s, %s, %s, %s)",
                        (str(uuid.uuid4()), variant['id'], warehouse_id, stock, stock),
                        commit=True
                    )
            
        # Update image if provided
        if data.get('image'):
            img_exists = execute_query("SELECT id FROM product_images WHERE product_id = %s LIMIT 1", (product_id,), fetch=True)
            if img_exists:
                execute_query("UPDATE product_images SET image_url = %s WHERE product_id = %s", (data.get('image'), product_id), commit=True)
            else:
                execute_query("INSERT INTO product_images (id, product_id, image_url, is_primary) VALUES (%s, %s, %s, True)", (str(uuid.uuid4()), product_id, data.get('image')), commit=True)
            
        return jsonify({"success": True, "message": "Product updated successfully"}), 200
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 400
