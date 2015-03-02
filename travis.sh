#!/bin/sh

IMAGE=coopernurse/barrister-conform

docker pull $IMAGE
docker run $IMAGE
