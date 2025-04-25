#!/bin/bash -x

if [ ! -f .env ]; then
    echo "there should be an .env file with YOUR configuration"
    exit -1
fi

UID=`id -u`
source .env
export DOCKER DOCKER_SOCKET DOCKER_HOST SKIP_DOMAIN_VALIDATION PULL UID \
  MY_IPV4_ADDR HOST_CONTAINER_INTERNAL HOST6_CONTAINER_INTERNAL NEXTCLOUD_MOUNT \
  AIO_BASE_DOMAIN AIO_DOMAIN AIO_SUBDOMAIN1 AIO_SUBDOMAIN2 \
  OTHER_BASE_DOMAIN OTHER_SUBDOMAIN1 OTHER_SUBDOMAIN2 OTHER_SUBDOMAIN3

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
  nextcloud-aio-domaincheck \
  nextcloud-aio-borgbackup


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
  nextcloud-aio-domaincheck \
  nextcloud-aio-borgbackup

