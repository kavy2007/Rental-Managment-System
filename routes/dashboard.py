from flask import Blueprint, jsonify
from db import execute_query

dashboard_bp = Blueprint('dashboard', __name__)

@dashboard_bp.route('/kpis', methods=['GET'])
def get_kpis():
    """Get dashboard KPIs from the database"""
    try:
        # Active Rentals
        active_rentals_q = "SELECT COUNT(*) as count FROM rental_orders WHERE status IN ('Confirmed', 'Paid')"
        active_rentals = execute_query(active_rentals_q, fetch=True)['count']
        
        # Revenue (Total Paid)
        revenue_q = "SELECT SUM(amount) as total FROM payments WHERE status = 'Paid'"
        revenue_result = execute_query(revenue_q, fetch=True)
        revenue = float(revenue_result['total'] or 0)
        
        # Deposits Held
        deposits_q = "SELECT SUM(security_deposit) as total FROM rental_orders WHERE status IN ('Active Rental', 'Picked Up')"
        deposits_result = execute_query(deposits_q, fetch=True)
        deposits = float(deposits_result['total'] or 0)
        
        return jsonify({
            "activeRentals": active_rentals,
            "dueToday": 0, # Placeholder for date logic
            "upcomingPickups": 0,
            "upcomingReturns": 0,
            "overdue": 0,
            "revenue": f"₹{revenue:,.0f}",
            "depositsHeld": f"₹{deposits:,.0f}",
            "lateFees": "₹0"
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
