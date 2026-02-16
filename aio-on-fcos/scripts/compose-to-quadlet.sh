#!/bin/bash -x

# you need:
#
# * go install github.com/mikefarah/yq/v4@latest
#   from https://github.com/mikefarah/yq
#   podlet 0.3.0
# * cargo install podlet
#   yq (https://github.com/mikefarah/yq/) version v4.50.1
# * for RHEL 9.4 yq is available: dnf install yp

set -euo pipefail
GIT_ROOT=`git rev-parse --show-toplevel`

pushd $GIT_ROOT/aio-on-fcos

NAME=$(yq '.name' compose.yaml)
TARGET_DIR=~/.config/containers/systemd
DOCKER_SOCKET=/run/user/$UID/podman/podman.sock
. .env

# ensure output directory
mkdir -p $TARGET_DIR | true

envsubst < $1 \
  | yq '(.volumes[] | select(has("external")) | .external) = false |
    (.networks[] | select(has("external")) | .external) = false |
    del(.services.*.extra_hosts) |
    .services.caddy |= (. | del(.build) | .image = "docker.io/library/caddy:latest") |
    del(.volumes.nextcloud_aio_mastercontainer.name)' \
  | tee c.yaml \
  | podlet -u -a --overwrite compose --pod -

# -p 4.8 podman version 4.8: RHEL 9.4 has podman 4.9 but then --pod could NOT be given

for i in $TARGET_DIR/${NAME}-* $TARGET_DIR/${NAME}_* $TARGET_DIR/${NAME}.*; do
  BASE=$(basename $i)
  rm $PWD/quadlets.template/$BASE || true
  ln -f $i $PWD/quadlets.template/$BASE || true
done

popd

systemctl --user daemon-reload
