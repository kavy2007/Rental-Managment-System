# 🏢 RentX – Enterprise Rental Management System

> A full-stack Rental Management System developed for enterprise rental businesses to simplify product rentals, automate workflows, and manage the complete rental lifecycle from booking to return.

---

# 📌 Overview

RentX is a web-based rental platform where customers can rent products online while administrators manage inventory, pricing, orders, security deposits, invoices, returns, and payments from a centralized dashboard.

The system is inspired by enterprise rental solutions like **Odoo Rental** and is built using a simple and beginner-friendly full-stack architecture.

---

# 🚀 Features

## 👤 Authentication
- User Registration
- User Login
- Password Encryption
- Profile Management

---

## 🛍 Product Management

- Browse Rental Products
- Product Categories
- Product Images
- Product Variants
- Product Details
- Search Products

---

## 🛒 Cart System

- Add to Cart
- Remove from Cart
- Update Quantity
- Rental Date Selection
- Calculate Rental Price

---

## 📅 Rental Management

- Create Rental Order
- Rental Schedule
- Rental Duration
- Security Deposit
- Rental Status Tracking
- Order History

---

## 💳 Payment System

- Razorpay Test Mode Integration
- Online Payment
- Payment Verification
- Payment Records
- Invoice Generation

---

## 📄 Invoice System

- Auto-generated Invoice
- Customer Details
- Rental Summary
- Security Deposit
- Tax Calculation
- Total Amount

---

## 📦 Inventory Management

- Warehouse Management
- Product Stock
- Available Quantity
- Reserved Quantity
- Rented Quantity
- Inventory Tracking

---

## 🔄 Return Management

- Product Return
- Late Return Tracking
- Security Deposit Refund
- Penalty Calculation
- Return Status

---

## 📊 Dashboard

- Total Products
- Active Rentals
- Revenue
- Customers
- Orders
- Inventory Status

---

# 🛠 Tech Stack

## Frontend

- HTML5
- CSS3
- JavaScript (Vanilla JS)

---

## Backend

- Python
- Flask
- Flask Blueprint
- Flask CORS

---

## Database

- MySQL

---

## Payment Gateway

- Razorpay Test Mode

---

## Password Security

- Werkzeug Password Hashing

---

## Version Control

- Git
- GitHub

---

# 📂 Project Structure

```
RentX/
│
├── app.py
├── db.py
├── requirements.txt
│
├── routes/
│   ├── auth.py
│   ├── products.py
│   ├── orders.py
│   ├── payments.py
│   └── dashboard.py
│
├── frontend/
│   ├── css/
│   ├── js/
│   ├── pages/
│   └── assets/
│
├── database/
│   └── rental_management.sql
│
└── README.md
```

---

# ⚙️ Installation

## 1 Clone Repository

```bash
git clone https://github.com/yourusername/RentX.git

cd RentX
```

---

## 2 Create Virtual Environment

```bash
python -m venv venv
```

Activate

Windows

```bash
venv\Scripts\activate
```

Linux / Mac

```bash
source venv/bin/activate
```

---

## 3 Install Dependencies

```bash
pip install -r requirements.txt
```

---

## 4 Create Database

```sql
CREATE DATABASE rental_management;
```

Import the SQL file into MySQL.

---

## 5 Configure Database

Inside **app.py**

```python
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'your_password'
app.config['MYSQL_DB'] = 'rental_management'
```

---

## 6 Run Server

```bash
python app.py
```

Backend runs at

```
http://localhost:5000
```

---

## 7 Open Frontend

Open

```
frontend/index.html
```

or use

```
Live Server
```

---

# 🔌 REST APIs

## Authentication

| Method | Endpoint |
|---------|----------|
| POST | /api/auth/register |
| POST | /api/auth/login |

---

## Products

| Method | Endpoint |
|---------|----------|
| GET | /api/products |
| GET | /api/products/<id> |

---

## Orders

| Method | Endpoint |
|---------|----------|
| GET | /api/orders |
| POST | /api/orders |
| GET | /api/orders/<id> |

---

## Payments

| Method | Endpoint |
|---------|----------|
| POST | /api/payments/create-order |
| POST | /api/payments/verify |

---

## Dashboard

| Method | Endpoint |
|---------|----------|
| GET | /api/dashboard |

---

# 🗄 Database Modules

- Users
- Customers
- Roles
- Products
- Categories
- Product Variants
- Inventory
- Warehouses
- Rental Orders
- Rental Order Items
- Payments
- Razorpay Transactions
- Invoices
- Returns
- Reports

---

# 🔐 Security

- Password Hashing
- UUID Primary Keys
- SQL Parameterized Queries
- CORS Enabled
- Soft Delete Ready
- REST API Architecture

---

# 💳 Razorpay Workflow

1. User places an order.
2. Flask creates a Razorpay Order.
3. Razorpay Checkout opens.
4. Customer completes payment.
5. Payment is verified.
6. Database updates payment status.
7. Rental Order status changes to **Paid**.
8. Invoice becomes available.

---

# 📄 Rental Workflow

Customer Login

↓

Browse Products

↓

Select Rental Duration

↓

Add to Cart

↓

Checkout

↓

Create Rental Order

↓

Pay via Razorpay

↓

Payment Verification

↓

Generate Invoice

↓

Pickup Product

↓

Return Product

↓

Deposit Refund

↓

Rental Completed

---

# 🎯 Future Enhancements

- Email Notifications
- SMS Alerts
- QR Code Pickup
- Barcode Scanner
- Product Availability Calendar
- Advanced Reports
- Multi-Vendor Support
- Predictive Maintenance
- Mobile Application

---

# 👨‍💻 Developed By

**Kavy Patel**<br>
**Prem Patel**<br>
**Pankti Patel**<br>
**Mahi Patel**

Computer Engineering Student

LDRP Institute of Technology and Research

Ahmedabad, Gujarat

---

# 📜 License

This project is developed for educational and hackathon purposes.

© 2026 RentX. All Rights Reserved.
