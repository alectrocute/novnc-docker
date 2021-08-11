#!/bin/bash -eux
docker build . --tag orca
docker rm -f orca || true
docker run \
  --detach \
  --env DISPLAY_SETTINGS="1280x720x24" \
  --publish 8080:8080 \
  --publish 8081:8081 \
  --rm \
  --name orca \
  orca
sleep 3
open -a "Google Chrome" http://localhost:8080