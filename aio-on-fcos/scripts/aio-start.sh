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

envsubst <./scripts/Caddyfile >./caddy/Caddyfile
# format
$DOCKER run --rm -v caddy:/etc/caddy:z docker.io/library/caddy:latest \
  caddy fmt --overwrite /etc/caddy/Caddyfile

rm -r coredns
mkdir coredns
envsubst <./coredns-template/Corefile >./coredns/Corefile
envsubst <./coredns-template/nextcloud-domain >./coredns/nextcloud-domain

if [ $PULL == "true" ]; then

$DOCKER pull ghcr.io/nextcloud-releases/all-in-one:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-postgresql:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-redis:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-watchtower:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-domaincheck:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-notify-push:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-apache:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-borgbackup:latest

$DOCKER pull ghcr.io/nextcloud-releases/all-whiteboard:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-talk:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-collabora:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-fulltextsearch:latest
$DOCKER pull ghcr.io/nextcloud-releases/aio-imaginary:latest

$DOCKER pull docker.io/library/caddy:latest

$DOCKER compose pull
fi

$DOCKER compose -p aio up -d
$DOCKER compose -p aio logs -f
