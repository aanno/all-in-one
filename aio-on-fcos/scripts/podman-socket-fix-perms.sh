#!/bin/bash -x

# www-data in container (id=33)
MY_UID=720928
MY_GID=720928

USERID=`id -u nc`

export DOCKER_SOCKET=/run/user/$USERID/podman/podman.sock
export DOCKER_HOST=unix://$DOCKER_SOCKET
echo "export DOCKER_SOCKET=$DOCKER_SOCKET"
echo "export DOCKER_HOST=$DOCKER_HOST"

# sudo chown -R $MY_UID:$MY_GID /run/user/$UID/podman
chgrp $MY_GID $DOCKER_SOCKET
chmod g+rw o-rwx $DOCKER_SOCKET

podman system connection list

curl -H "Content-Type: application/json" \
	--unix-socket /run/user/$USERID/podman/podman.sock \
    http://localhost/_ping
echo ""

ls -l $DOCKER_SOCKET
