from flask import Flask, send_from_directory

app = Flask(__name__)

@app.route('/')
@app.route('/<path:path_to_file>')
def serve_file(path_to_file='index.html'):
    return send_from_directory('site', path_to_file)
