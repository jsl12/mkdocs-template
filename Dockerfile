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
