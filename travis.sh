#!/bin/sh

IMAGE=coopernurse/barrister-conform

docker -d &
sleep 2
docker pull $IMAGE
docker run $IMAGE
