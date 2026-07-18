import os
from flask import Flask, jsonify, request
from flask_cors import CORS
from db import init_db

# Import Blueprints (We'll create these next)
from routes.auth import auth_bp
from routes.products import products_bp
# from routes.categories import categories_bp
# from routes.customers import customers_bp
from routes.orders import orders_bp
# from routes.inventory import inventory_bp
from routes.payments import payments_bp
# from routes.returns import returns_bp
from routes.dashboard import dashboard_bp

app = Flask(__name__)

# Enable CORS for all routes so the frontend can communicate with the backend
CORS(app)

# MySQL Database Configuration
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Prem@2007' # Update if your MySQL root has a password
app.config['MYSQL_DB'] = 'rental_management'

# Initialize the database
init_db(app)

# Register Blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(products_bp, url_prefix='/api/products')
# app.register_blueprint(categories_bp, url_prefix='/api/categories')
# app.register_blueprint(customers_bp, url_prefix='/api/customers')
app.register_blueprint(orders_bp, url_prefix='/api/orders')
# app.register_blueprint(inventory_bp, url_prefix='/api/inventory')
app.register_blueprint(payments_bp, url_prefix='/api/payments')
# app.register_blueprint(returns_bp, url_prefix='/api/returns')
app.register_blueprint(dashboard_bp, url_prefix='/api/dashboard')

@app.route('/api/health', methods=['GET'])
def health_check():
    """Simple health check endpoint"""
    return jsonify({"status": "healthy", "message": "RentX API is running"}), 200

# Error Handling
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    # Run the app in debug mode on port 5000
    app.run(debug=True, port=5000)
