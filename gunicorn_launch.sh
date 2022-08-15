#!/bin/sh

mkdocs build --config-file mkdocs.yml --site-dir site/

gunicorn -b 0.0.0.0:${PORT:-$1} --worker-tmp-dir /dev/shm --workers=2 app:app
