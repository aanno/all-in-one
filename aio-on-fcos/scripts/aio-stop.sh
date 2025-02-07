#!/bin/bash -x

if [ ! -f .env ]; then
    echo "there should be an .env file with YOUR configuration"
    exit -1
fi
source .env
export DOCKER DOCKER_SOCKET DOCKER_HOST AIO_DOMAIN SKIP_DOMAIN_VALIDATION \
  MY_IPV4_ADDR HOST_CONTAINER_INTERNAL HOST6_CONTAINER_INTERNAL NEXTCLOUD_MOUNT

$DOCKER compose -p aio down

sleep 2

$DOCKER stop \
  caddy \
  nextcloud-aio-apache \
  nextcloud-aio-notify-push \
  nextcloud-aio-nextcloud \
  nextcloud-aio-database \
  nextcloud-aio-redis \
  nextcloud-aio-whiteboard \
  nextcloud-aio-fulltextsearch \
  nextcloud-aio-talk \
  nextcloud-aio-collabora \
  nextcloud-aio-watchtower  nextcloud-aio-apache \
  nextcloud-aio-notify-push \
  nextcloud-aio-nextcloud \
  nextcloud-aio-database \
  nextcloud-aio-redis \
  nextcloud-aio-whiteboard \
  nextcloud-aio-fulltextsearch \
  nextcloud-aio-talk \
  nextcloud-aio-collabora \
  nextcloud-aio-imaginary \
  nextcloud-aio-watchtower \
  nextcloud-aio-domaincheck


$DOCKER rm -f \
  caddy \
  nextcloud-aio-apache \
  nextcloud-aio-notify-push \
  nextcloud-aio-nextcloud \
  nextcloud-aio-database \
  nextcloud-aio-redis \
  nextcloud-aio-whiteboard \
  nextcloud-aio-fulltextsearch \
  nextcloud-aio-talk \
  nextcloud-aio-collabora \
  nextcloud-aio-watchtower  nextcloud-aio-apache \
  nextcloud-aio-notify-push \
  nextcloud-aio-nextcloud \
  nextcloud-aio-database \
  nextcloud-aio-redis \
  nextcloud-aio-whiteboard \
  nextcloud-aio-fulltextsearch \
  nextcloud-aio-talk \
  nextcloud-aio-collabora \
  nextcloud-aio-imaginary \
  nextcloud-aio-watchtower \
  nextcloud-aio-domaincheck

