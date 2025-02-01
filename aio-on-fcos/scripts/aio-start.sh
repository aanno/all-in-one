#!/bin/bash -x

if [ ! -f .env ]; then
    echo "there should be an .env file with YOUR configuration"
    exit -1
fi
source .env
export DOCKER DOCKER_SOCKET DOCKER_HOST AIO_DOMAIN SKIP_DOMAIN_VALIDATION MY_IPV4_ADDR

envsubst <./scripts/Caddyfile >./caddy/Caddyfile

$DOCKER pull docker.io/nextcloud/all-in-one:latest
$DOCKER pull docker.io/nextcloud/aio-postgresql:latest
$DOCKER pull docker.io/nextcloud/aio-redis:latest
$DOCKER pull docker.io/nextcloud/aio-watchtower:latest
$DOCKER pull docker.io/nextcloud/aio-domaincheck:latest
$DOCKER pull docker.io/nextcloud/aio-notify-push:latest
$DOCKER pull docker.io/nextcloud/aio-apache:latest
$DOCKER pull docker.io/library/caddy:latest 

$DOCKER compose pull
$DOCKER compose -p aio up -d
$DOCKER compose -p aio logs -f
