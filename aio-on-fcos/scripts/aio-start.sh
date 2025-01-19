#!/bin/bash -x

if [ ! -f .env ]; then
    echo "there should be an .env file with YOUR configuration"
    exit -1
fi
source .env

envsubst <./scripts/Caddyfile >./caddy/Caddyfile
