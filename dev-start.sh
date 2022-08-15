#!/bin/sh

docker build -t docs:custom .

docker run \
  --rm -d \
  -v ${PWD}:/docs \
  -p $1:$1 \
  docs:custom \
  mkdocs serve --dev-addr=0.0.0.0:$1
