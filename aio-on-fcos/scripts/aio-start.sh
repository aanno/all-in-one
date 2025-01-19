#!/bin/bash -x

if [ ! -f .env ]; then
    echo "there should be an .env file with YOUR configuration"
    exit -1
fi
source .env
export DOCKER DOCKER_SOCKET DOCKER_HOST AIO_DOMAIN SKIP_DOMAIN_VALIDATION

envsubst <./scripts/Caddyfile >./caddy/Caddyfile

$DOCKER compose -p aio up -d
$DOCKER compose -p aio logs -f
