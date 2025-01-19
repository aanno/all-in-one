#!/bin/bash -x

if [ ! -f .env ]; then
    echo "there should be an .env file with YOUR configuration"
    exit -1
fi
source .env
export DOCKER DOCKER_SOCKET DOCKER_HOST AIO_DOMAIN SKIP_DOMAIN_VALIDATION MY_IPV4_ADDR

$DOCKER compose -p aio down

sleep 2

$DOCKER rm -f \
  nextcloud-aio-apache \
  nextcloud-aio-notify-push \
  nextcloud-aio-nextcloud \
  nextcloud-aio-database \
  nextcloud-aio-redis
