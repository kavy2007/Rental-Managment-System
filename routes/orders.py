from flask import Blueprint, request, jsonify
from db import execute_query
import uuid

orders_bp = Blueprint('orders', __name__)

@orders_bp.route('/', methods=['GET'])
def get_orders():
    try:
        query = """
            SELECT 
                o.id, 
                o.status, 
                o.total_amount, 
                DATE_FORMAT(o.created_at, '%Y-%m-%d') as date,
                DATE_FORMAT((SELECT MAX(end_date) FROM rental_order_items WHERE order_id = o.id), '%Y-%m-%d') as return_date,
                COALESCE(CONCAT(up.first_name, ' ', up.last_name), c.email) as customer
            FROM rental_orders o
            LEFT JOIN customers c ON o.customer_id = c.id
            LEFT JOIN users u ON c.email = u.email
            LEFT JOIN user_profiles up ON up.user_id = u.id
            ORDER BY o.created_at DESC
        """
        orders = execute_query(query, fetchall=True)
        
        formatted_orders = []
        for o in orders:
            formatted_orders.append({
                "id": o['id'][:8].upper(), # Shorter ID for display
                "full_id": o['id'], # Full ID for links
                "customer": o['customer'] or "Unknown",
                "date": o['date'],
                "return_date": o['return_date'] or "N/A",
                "total": float(o['total_amount']),
                "status": o['status']
            })
            
        return jsonify(formatted_orders), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@orders_bp.route('/', methods=['POST'])
def create_order():
    data = request.json
    print(f"[DEBUG] create_order payload received: {data}")
    try:
        # Expected data: { customer_id: "...", items: [{variant_id, quantity, price, start_date, end_date}] }
        order_id = str(uuid.uuid4())
        frontend_user_id = data.get('customer_id')
        items = data.get('items', [])
        
        if not frontend_user_id or not items:
            return jsonify({"success": False, "message": "Missing customer_id or items"}), 400

        # Look up email from users table to find the actual customer ID
        user_data = execute_query("SELECT email FROM users WHERE id = %s", (frontend_user_id,), fetch=True)
        if not user_data:
            return jsonify({"success": False, "message": "Invalid user ID"}), 400
            
        customer_data = execute_query("SELECT id FROM customers WHERE email = %s", (user_data['email'],), fetch=True)
        if not customer_data:
            # Auto-create if missing
            real_customer_id = str(uuid.uuid4())
            execute_query("INSERT INTO customers (id, email) VALUES (%s, %s)", (real_customer_id, user_data['email']), commit=True)
        else:
            real_customer_id = customer_data['id']
            
        customer_id = real_customer_id
            
        # Calculate total rental cost, security deposit, and total amount with tax
        rental_subtotal = sum(item.get('price', 0) * item.get('quantity', 1) * item.get('duration', 1) for item in items)
        total_deposit = sum(item.get('security_deposit', 0) * item.get('quantity', 1) for item in items)
        tax = rental_subtotal * 0.1
        total_amount = rental_subtotal + total_deposit + tax
        
        # Insert Order
        execute_query(
            "INSERT INTO rental_orders (id, customer_id, status, total_amount, security_deposit) VALUES (%s, %s, 'Confirmed', %s, %s)",
            (order_id, customer_id, total_amount, total_deposit),
            commit=True
        )
        
        # Insert Order Items
        for item in items:
            item_id = str(uuid.uuid4())
            frontend_item_id = item['variant_id']
            
            # The frontend sends the product ID as 'variant_id'. We need to look up the actual variant ID.
            variant_data = execute_query("SELECT id FROM product_variants WHERE product_id = %s LIMIT 1", (frontend_item_id,), fetch=True)
            if not variant_data:
                # If it's already a variant ID, verify it exists
                variant_check = execute_query("SELECT id FROM product_variants WHERE id = %s LIMIT 1", (frontend_item_id,), fetch=True)
                if not variant_check:
                    raise Exception(f"Product not found: {frontend_item_id}")
                actual_variant_id = frontend_item_id
            else:
                actual_variant_id = variant_data['id']

            execute_query(
                "INSERT INTO rental_order_items (id, order_id, variant_id, quantity, unit_price, start_date, end_date) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                (item_id, order_id, actual_variant_id, item['quantity'], item['price'], item['start_date'], item['end_date']),
                commit=True
            )
            
        print(f"[DEBUG] create_order success: {order_id}")
        return jsonify({"success": True, "message": "Order created successfully", "order_id": order_id}), 201
    except Exception as e:
        print(f"[ERROR] create_order failed: {e}")
        return jsonify({"success": False, "message": str(e)}), 400

@orders_bp.route('/<order_id>', methods=['GET'])
def get_order(order_id):
    try:
        # Get order details
        order_query = """
            SELECT 
                o.id, o.status, o.total_amount, o.security_deposit, DATE_FORMAT(o.created_at, '%%Y-%%m-%%d') as date,
                DATE_FORMAT((SELECT MAX(end_date) FROM rental_order_items WHERE order_id = o.id), '%%Y-%%m-%%d') as return_date,
                c.email as customer_email,
                COALESCE(CONCAT(up.first_name, ' ', up.last_name), c.email) as customer_name
            FROM rental_orders o
            LEFT JOIN customers c ON o.customer_id = c.id
            LEFT JOIN users u ON c.email = u.email
            LEFT JOIN user_profiles up ON up.user_id = u.id
            WHERE o.id = %s
        """
        order = execute_query(order_query, (order_id,), fetch=True)
        
        if not order:
            return jsonify({"error": "Order not found"}), 404
            
        # Get order items
        items_query = """
            SELECT 
                roi.quantity, roi.unit_price as price, DATE_FORMAT(roi.start_date, '%%Y-%%m-%%d') as start_date, DATE_FORMAT(roi.end_date, '%%Y-%%m-%%d') as end_date,
                p.name as product_name
            FROM rental_order_items roi
            LEFT JOIN product_variants pv ON roi.variant_id = pv.id
            LEFT JOIN products p ON pv.product_id = p.id
            WHERE roi.order_id = %s
        """
        items = execute_query(items_query, (order_id,), fetchall=True)
        
        return jsonify({
            "id": order['id'],
            "status": order['status'],
            "total": float(order['total_amount']),
            "security_deposit": float(order['security_deposit']),
            "date": order['date'],
            "customer_email": order['customer_email'],
            "customer_name": order['customer_name'] or order['customer_email'],
            "return_date": order['return_date'] or "N/A",
            "items": items
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
