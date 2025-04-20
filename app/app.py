import logging
from flask import Flask

# Configure logging
logging.basicConfig(level=logging.INFO)
logging.info("Starting the application...")

app = Flask(__name__)

@app.route('/')
def home():
    logging.info("Home route accessed.")
    return "Hello, World!"

if __name__ == "__main__":
    logging.info("App is running successfully.")
    app.run(host='0.0.0.0', port=8000)

