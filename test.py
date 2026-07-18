import urllib.request, json
data = json.dumps({'email': 'test7@test.com', 'password': '123', 'name': 'Test User'})
req = urllib.request.Request('http://localhost:5000/api/auth/register', data=data.encode('utf-8'), headers={'Content-Type': 'application/json'})
try:
    with urllib.request.urlopen(req) as response:
        print(response.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print(f"HTTP {e.code}")
    print(e.read().decode('utf-8'))
except Exception as e:
    print(e)
