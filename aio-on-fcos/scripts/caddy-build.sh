#!/bin/bash -x

pushd caddy_build

  podman build -t localhost/caddy:latest -t localhost/aio_caddy:latest --rm .

popd
