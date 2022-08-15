# Mkdocs

## General Notes
The project folder needs to be mounted into `/docs` either by the `docker run` command or the `docker-compose` file

The port 8824 can be changed to anything.

Gunicorn’s main process starts one or more worker processes, and restarts them if they die. To ensure the workers are still alive, Gunicorn has a heartbeat system—which works by using a file on the filesystem. Gunicorn therefore recommends that this file be stored in a memory-only part of the filesystem.[^1]

## Usage

### Build Image
```
docker build -t docs:custom .
```

### Run Image - Development
Needs to be run from the project folder. Container removes itself after it's stopped.
```
docker run \
  --rm -d \
  -v ${PWD}:/docs \
  -p 8824:8824 \
  docs:custom \
  mkdocs serve --dev-addr=0.0.0.0:8824
```

### Run Image - Production
```
docker run \
  --rm -d \
  -v ${PWD}:/docs \
  -p 8824:8824 \
  -e PORT=8824 \
  docs:custom
```

#### `docker-compose`
Assumes that the compose file will be in the same parent folder that contains the documentation folder (`./docs` in this case)
```yaml
docs:
  container_name: docs
  image: docs:custom
  build: ./docs
  volumes:
    - ./docs:/docs
  ports:
    - 8824:8824
```

## Project Structure
```
./
|-- docs/
|-- site/
|-- app.py
|-- Dockerfile
|-- compose.yaml
|-- mkdocs.yml
|-- app.py
`-- start.sh
```

## Files

### `Dockerfile`
```docker title="Dockerfile"
FROM python:slim

RUN apt update && \
    apt full-upgrade -y && \
    python -m pip install --upgrade pip

RUN pip install gunicorn flask mkdocs mkdocs-material

WORKDIR /docs

COPY docs docs
COPY mkdocs.yml mkdocs.yml
COPY gunicorn_launch.sh gunicorn_launch.sh
RUN chmod +x gunicorn_launch.sh
CMD ./gunicorn_launch.sh
```

### `app.py`
Contains a barebones `Flask` server that will serve up any of the files in `site/`.
```python title="app.py"
from flask import Flask, send_from_directory

app = Flask(__name__)

@app.route('/')
@app.route('/<path:path_to_file>')
def serve_file(path_to_file='index.html'):
    return send_from_directory('site', path_to_file)
```

### `gunicorn_launch.sh`
Shell script to rebuild the documentation when the container starts. This allows the documentation to be updated in production by simply restarting the container.
```shell title="gunicorn_launch.sh"
#!/bin/sh

mkdocs build --config-file mkdocs.yml --site-dir site/

gunicorn -b 0.0.0.0:${PORT:-$1} --worker-tmp-dir /dev/shm --workers=2 app:app
```

[^1]:[`gunicorn` in Docker](https://pythonspeed.com/articles/gunicorn-in-docker/)
