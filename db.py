from flask_mysqldb import MySQL

mysql = MySQL()

def init_db(app):
    """Initialize the MySQL extension with the Flask app."""
    mysql.init_app(app)

def get_db():
    """Get the database connection."""
    return mysql.connection

def get_cursor(dictionary=True):
    """Get a database cursor. If dictionary is True, returns DictCursor."""
    # Flask-MySQLdb's default cursor returns tuples. We often want dictionaries.
    if dictionary:
        from MySQLdb.cursors import DictCursor
        return mysql.connection.cursor(DictCursor)
    return mysql.connection.cursor()

def execute_query(query, params=None, fetch=False, fetchall=False, commit=False):
    """
    Helper function to execute a query.
    - query: SQL query string
    - params: Tuple of parameters for the query
    - fetch: Boolean, if True returns fetchone()
    - fetchall: Boolean, if True returns fetchall()
    - commit: Boolean, if True commits the transaction
    """
    cursor = get_cursor(dictionary=True)
    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
            
        result = None
        if fetchall:
            result = cursor.fetchall()
        elif fetch:
            result = cursor.fetchone()
            
        if commit:
            mysql.connection.commit()
            
        return result
    except Exception as e:
        # In a real app, log this error
        print(f"Database error: {e}")
        if commit:
            mysql.connection.rollback()
        raise e
    finally:
        cursor.close()
