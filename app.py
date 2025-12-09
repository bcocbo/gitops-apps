
from flask import Flask, jsonify
from datetime import datetime
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from test-app04!',
        'environment': 'dev',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    print(f'🚀 test-app04 listening on port {port}')
    print(f'📊 Environment: dev')
    print(f'✅ Health check: http://localhost:{port}/health')
    app.run(host='0.0.0.0', port=port)

