from flask import Flask
from flask_cors import CORS
from rdp_monitor_API import rdp_monitor_api

app = Flask(__name__)
CORS(app)

# Blueprint 등록
app.register_blueprint(rdp_monitor_api, url_prefix="/rdp")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)