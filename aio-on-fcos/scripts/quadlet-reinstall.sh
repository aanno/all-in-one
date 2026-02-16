#!/bin/bash -x

# you need:
#
# * cargo install podlet
#   yq (https://github.com/mikefarah/yq/) version v4.50.1
# * for RHEL 9.4 yq is available: dnf install yp

set -euo pipefail

# export ALL that is needed in envsubst
# this is need for a interpolation directly in *.container files
export GIT_ROOT=`git rev-parse --show-toplevel`

pushd $GIT_ROOT

source .env
export HOME USERID SONAR_JDBC_PASSWORD SONAR_JDBC_USERNAME SONAR_POSTGRES_DB

NAME=$(yq '.name' docker-compose.yml)
TARGET_DIR=~/.config/containers/systemd

# ensure output directory
mkdir -p $TARGET_DIR | true
systemctl --user stop sonarqube-pod.service || true

systemctl --user reset-failed sonarqube-caddy.service || true
systemctl --user reset-failed sonarqube-grafana.service || true
# systemctl --user reset-failed sonarqube-network.service || true
systemctl --user reset-failed sonarqube-pg_sonar_exporter.service || true
systemctl --user reset-failed sonarqube-pg_sonar.service || true
systemctl --user reset-failed sonarqube-pod.service || true
systemctl --user reset-failed sonarqube-prometheus.service || true
systemctl --user reset-failed sonarqube-sonarqube.service || true

for i in quadlets.template/*; do
  # restrict access as there might be passwords in these files
  chmod go-rwx $i
  BASE=$(basename $i)
  rm quadlets/$BASE || true
  envsubst '$GIT_ROOT $HOME $USERID $SONAR_JDBC_PASSWORD $SONAR_JDBC_USERNAME $SONAR_POSTGRES_DB' <$i >quadlets/$BASE
  # restrict access as there might be passwords in these files
  chmod go-rwx quadlets/$BASE
done

for i in quadlets/*; do
  BASE=$(basename $i)
  rm $TARGET_DIR/$BASE || true
  ln -f $i $TARGET_DIR/$BASE
done

popd

systemctl --user daemon-reload
# sleep 1
# systemctl --user start sonarqube-pod.service
# sleep 2
# systemctl --user status sonarqube-pod.service
