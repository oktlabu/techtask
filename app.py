from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello_world():
    return jsonify(message="Hello, Risktec!")

@app.route('/api/data', methods=['GET'])
def get_data():
    data = {
        "name": "Sample API",
        "version": "1.0",
        "description": "This is a sample API built with Flask created by Abu"
    }
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
