#!/bin/bash

if [ ! -f .env ]; then
    echo "there should be an .env file with YOUR configuration"
    exit -1
fi
source .env
export DOCKER DOCKER_SOCKET DOCKER_HOST AIO_DOMAIN SKIP_DOMAIN_VALIDATION MY_IPV4_ADDR

export CONTAINERS="nextcloud-aio-mastercontainer nextcloud-aio-collabora nextcloud-aio-talk nextcloud-aio-database nextcloud-aio-redis nextcloud-aio-fulltextsearch nextcloud-aio-imaginary nextcloud-aio-nextcloud nextcloud-aio-notify-push nextcloud-aio-whiteboard nextcloud-aio-apache caddy"
export CONAINERS="nextcloud-aio-talk"

for i in $CONTAINERS; do
  echo $i
  podman exec --user root -it $i sh -c 'sed -e "/host.docker.internal$/ s/$/ nextcloud.breitbandig.de/" /etc/hosts >/tmp/hosts'
  # podman exec --user root -it $i sh -c 'echo -e "cp /etc/hosts /tmp/hosts;\nsed -ie "/host.docker.internal$/ s/$/ nextcloud.breitbandig.de/" /tmp/hosts
done
