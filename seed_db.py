import MySQLdb
import uuid

conn = MySQLdb.connect(host='localhost', user='root', password='Prem@2007', database='rental_management')
cursor = conn.cursor()

def insert_product(name, category, price, deposit, image_url, stock):
    p_id = str(uuid.uuid4())
    v_id = str(uuid.uuid4())
    
    # Insert Category
    c_id = str(uuid.uuid4())
    try:
        cursor.execute("INSERT INTO categories (id, name, slug) VALUES (%s, %s, %s)", (c_id, category, category.lower()))
    except MySQLdb.IntegrityError:
        cursor.execute("SELECT id FROM categories WHERE slug = %s", (category.lower(),))
        c_id = cursor.fetchone()[0]
    
    # Insert Product
    cursor.execute("INSERT INTO products (id, category_id, name, description, status) VALUES (%s, %s, %s, %s, 'Active')", 
                   (p_id, c_id, name, f"High quality {name}"))
                   
    # Insert Variant
    cursor.execute("INSERT INTO product_variants (id, product_id, sku, base_price, replacement_value) VALUES (%s, %s, %s, %s, %s)",
                   (v_id, p_id, f"SKU-{p_id[:6]}", price, deposit))
                   
    # Insert Image
    cursor.execute("INSERT INTO product_images (id, product_id, image_url, is_primary) VALUES (%s, %s, %s, 1)",
                   (str(uuid.uuid4()), p_id, image_url))
                   
    # Insert Inventory
    cursor.execute("INSERT INTO inventory (id, variant_id, quantity_available, quantity_total) VALUES (%s, %s, %s, %s)",
                   (str(uuid.uuid4()), v_id, stock, stock))

try:
    insert_product("MacBook Pro M2", "Electronics", 1500, 50000, "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&q=80&w=400", 5)
    insert_product("DJI Mavic 3 Drone", "Cameras", 2000, 60000, "https://images.unsplash.com/photo-1579829366248-204fe8413f31?auto=format&fit=crop&q=80&w=400", 3)
    insert_product("Canon EOS R5", "Cameras", 1800, 80000, "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=400", 2)
    insert_product("Sony PlayStation 5", "Gaming", 800, 40000, "https://images.unsplash.com/photo-1606813907291-d86efa9b94db?auto=format&fit=crop&q=80&w=400", 10)
    insert_product("Bose QuietComfort 45", "Audio", 300, 15000, "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&q=80&w=400", 15)
    
    conn.commit()
    print("Database seeded with sample products successfully!")
except Exception as e:
    print(f"Error: {e}")
    conn.rollback()
finally:
    conn.close()
