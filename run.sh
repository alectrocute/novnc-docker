#!/bin/bash -eux
docker kill $(docker ps -q) || true
docker rm $(docker ps -a -q) || true
docker rmi $(docker images -q) || true

docker build . --tag orca

docker run \
  --detach \
  --env DISPLAY_SETTINGS="1280x720x24" \
  --publish 8080:8083 \
  --rm \
  --name orca \
  orca
sleep 3
open -a "Google Chrome" http://localhost:8080