#!/bin/sh

IMAGE=coopernurse/barrister-conform

docker -d -H unix:///var/run/docker.sock &
sleep 2
docker pull $IMAGE
docker run $IMAGE
