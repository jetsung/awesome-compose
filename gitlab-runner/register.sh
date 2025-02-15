#!/usr/bin/env bash

docker exec -it gitlab-runner gitlab-runner register \
  --executor docker \
  --description "My Docker Runner" \
  --docker-image "docker:latest" \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock
