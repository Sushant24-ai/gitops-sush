from flask import Flask, jsonify, render_template
import os
import socket
import datetime

app = Flask(__name__)

# Configuration
PORT = int(os.environ.get("PORT", 5000))
VERSION = os.environ.get("VERSION", "1.0.0")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/info')
def info():
    return jsonify({
        'hostname': socket.gethostname(),
        'version': VERSION,
        'time': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    })

@app.route('/health')
def health():
    # For testing rollbacks, you can make this endpoint fail
    # if VERSION == "2.0.0-broken":
    #     return jsonify({'status': 'failure'}), 500
    
    return jsonify({
        'status': 'ok',
        'version': VERSION,
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/ready')
def ready():
    return jsonify({'status': 'ready'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)
