#!/bin/bash -x

UID=`id -u`

# www-data in container (id=33)
MY_UID=720928
MY_GID=720928

# old
# systemctl --user stop docker || true
# systemctl --user stop podman.socket || true
# systemctl --user restart podman.socket

export DOCKER_SOCKET=/run/user/$UID/podman/podman.sock
export DOCKER_HOST=unix://$DOCKER_SOCKET
echo "export DOCKER_SOCKET=$DOCKER_SOCKET"
echo "export DOCKER_HOST=$DOCKER_HOST"

mkdir /run/user/$UID/podman || true
touch $DOCKER_SOCKET
podman system service -t 0 $DOCKER_HOST &
# sudo chown -R $MY_UID:$MY_GID /run/user/$UID/podman

podman system connection list

curl -H "Content-Type: application/json" \
	--unix-socket /run/user/$UID/podman/podman.sock \
    http://localhost/_ping
echo ""

ls -l $DOCKER_SOCKET
