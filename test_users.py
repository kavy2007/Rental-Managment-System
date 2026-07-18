import urllib.request, json, MySQLdb
conn = MySQLdb.connect(host='localhost', user='root', password='Prem@2007', database='rental_management')
cursor = conn.cursor(MySQLdb.cursors.DictCursor)
cursor.execute('SELECT id FROM users')
users = cursor.fetchall()
cursor.execute('SELECT id FROM product_variants LIMIT 1')
variant = cursor.fetchone()

for user in users:
    req = urllib.request.Request('http://localhost:5000/api/orders/', 
        data=json.dumps({
            'customer_id': user['id'], 
            'items': [{'variant_id': variant['id'], 'quantity': 1, 'price': 100, 'start_date': '2026-01-01', 'end_date': '2026-01-02'}]
        }).encode('utf-8'), 
        headers={'Content-Type': 'application/json'}
    )
    try:
        resp = urllib.request.urlopen(req).read().decode('utf-8')
        print(f"User {user['id']} SUCCESS: {resp.strip()}")
    except Exception as e:
        error_msg = e.read().decode("utf-8").strip() if hasattr(e, 'read') else str(e)
        print(f"User {user['id']} ERROR: {error_msg}")
