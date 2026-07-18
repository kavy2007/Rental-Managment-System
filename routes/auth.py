from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from db import execute_query
import uuid

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Missing email or password"}), 400

    email = data.get('email')
    password = data.get('password')
    name = data.get('name', 'User') # Default name if not provided
    role = data.get('role', 'customer') # 'admin' or 'customer'

    # Hash the password
    hashed_password = generate_password_hash(password)
    
    # Generate UUID for the user
    user_id = str(uuid.uuid4())

    try:
        # Check if user already exists
        existing_user = execute_query("SELECT id FROM users WHERE email = %s", (email,), fetch=True)
        if existing_user:
            return jsonify({"error": "Email already registered"}), 400
        # Insert into users table
        execute_query(
            "INSERT INTO users (id, email, password_hash, is_active) VALUES (%s, %s, %s, %s)",
            (user_id, email, hashed_password, True),
            commit=True
        )
        
        # In a real app, we would assign roles and create customer profiles here based on the 'role'
        # For simplicity, we just create the user record.
        
        # If it's a customer, create a customer record too
        if role == 'customer':
            customer_id = str(uuid.uuid4())
            execute_query(
                "INSERT INTO customers (id, email, password_hash) VALUES (%s, %s, %s)",
                (customer_id, email, hashed_password),
                commit=True
            )
            
            # Also create a profile
            execute_query(
                "INSERT INTO user_profiles (user_id, first_name) VALUES (%s, %s)",
                (user_id, name),
                commit=True
            )

        return jsonify({"message": "User registered successfully", "userId": user_id}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Missing email or password"}), 400

    email = data.get('email')
    password = data.get('password')
    role = data.get('role', 'customer') # 'admin' or 'customer'

    try:
        # Check users table
        user = execute_query("SELECT id, password_hash FROM users WHERE email = %s", (email,), fetch=True)
        
        if not user or not check_password_hash(user['password_hash'], password):
            return jsonify({"error": "Invalid email or password"}), 401
            
        # Get user profile details
        profile = execute_query("SELECT first_name, gst_no, profile_photo FROM user_profiles WHERE user_id = %s", (user['id'],), fetch=True)
        name = profile['first_name'] if profile and profile.get('first_name') else email.split('@')[0]
        gst_no = profile['gst_no'] if profile else ''
        photo = profile['profile_photo'] if profile else ''

        # For a simple hackathon app, we can just return the user details. 
        # In a real app, we would issue a JWT token here.
        return jsonify({
            "message": "Login successful", 
            "user": {
                "id": user['id'],
                "email": email,
                "name": name,
                "role": role,
                "gst_no": gst_no,
                "profile_photo": photo
            }
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@auth_bp.route('/profile', methods=['PUT'])
def update_profile():
    data = request.json
    user_id = data.get('id')
    
    if not user_id:
        return jsonify({"error": "User ID is required"}), 400
        
    name = data.get('name')
    gst_no = data.get('gst_no')
    photo = data.get('profile_photo')
    
    try:
        # Check if profile exists
        profile = execute_query("SELECT id FROM user_profiles WHERE user_id = %s", (user_id,), fetch=True)
        if profile:
            execute_query(
                "UPDATE user_profiles SET first_name = %s, gst_no = %s, profile_photo = %s WHERE user_id = %s",
                (name, gst_no, photo, user_id),
                commit=True
            )
        else:
            execute_query(
                "INSERT INTO user_profiles (user_id, first_name, gst_no, profile_photo) VALUES (%s, %s, %s, %s)",
                (user_id, name, gst_no, photo),
                commit=True
            )
            
        return jsonify({"message": "Profile updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
