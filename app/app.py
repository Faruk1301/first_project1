from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
    if os.getenv('STAGING') == '1':
        return 'Hello from Staging'
    else:
        return 'Hello from Dev'

@app.route('/health')
def health():
    return 'OK', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

