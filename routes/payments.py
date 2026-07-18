from flask import Blueprint, request, jsonify
from db import execute_query
import uuid

payments_bp = Blueprint('payments', __name__)

import razorpay

RAZORPAY_KEY_ID = "rzp_test_TEyZ8nRU9yCuaR"
RAZORPAY_KEY_SECRET = "50HXUFSerkXW8hoVxFXwnuOS"
rzp_client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))

@payments_bp.route('/create-order', methods=['POST'])
def create_payment_order():
    """Create a real Razorpay order"""
    data = request.json
    amount = data.get('amount') # in rupees
    
    if not amount:
        return jsonify({"error": "Amount is required"}), 400

    try:
        rzp_order = rzp_client.order.create({
            'amount': int(amount * 100), 
            'currency': 'INR', 
            'payment_capture': '1'
        })
        
        return jsonify({
            "id": rzp_order['id'],
            "currency": "INR",
            "amount": int(amount * 100),
            "key": RAZORPAY_KEY_ID
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@payments_bp.route('/verify', methods=['POST'])
def verify_payment():
    """Verify payment and update db"""
    data = request.json
    try:
        payment_id = str(uuid.uuid4())
        order_id = data.get('order_id') # RentX order ID
        amount = data.get('amount')
        rzp_payment_id = data.get('razorpay_payment_id', f"pay_{uuid.uuid4().hex[:14]}")
        
        # Update order status to 'Paid'
        execute_query(
            "UPDATE rental_orders SET status = 'Paid' WHERE id = %s",
            (order_id,),
            commit=True
        )
        
        # Insert payment record
        execute_query(
            "INSERT INTO payments (id, order_id, amount, status, method) VALUES (%s, %s, %s, 'Paid', 'Razorpay')",
            (payment_id, order_id, amount),
            commit=True
        )
        
        return jsonify({"message": "Payment verified successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
