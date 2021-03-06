#!/bin/bash
# Usage: scrape-openshift.sh 3.10.0
# Available versions: https://hub.docker.com/r/openshift/origin/tags/

set -e -u -o pipefail

cd "$(dirname "$(dirname "$0")")"  # run from root of repo.

VERSION="v$1"

NAME="origin-$VERSION"

docker-verbose () {
  echo sudo docker "$@"
  sudo docker "$@"
}

# This may fail with "Conflict. The container name "/origin-v1.2.0" is already in use by container ..."
if docker ps --all | grep "$NAME"; then
  docker-verbose start "$NAME"
else
  docker-verbose run --detach --name "$NAME" \
       --privileged --pid=host --net=host \
       -v /:/rootfs:ro -v /var/run:/var/run:rw -v /sys:/sys -v /var/lib/docker:/var/lib/docker:rw \
       -v /var/lib/origin/openshift.local.volumes:/var/lib/origin/openshift.local.volumes \
       -- \
       "docker.io/openshift/origin:$VERSION" start
fi

env DIR=openshift-origin-"$VERSION" URL=https://localhost:8443 WAIT_OKS="healthz healthz/ready" tools/scrape.sh

echo
#docker ps --all --filter=name="$NAME"
#echo "# When done run:"
#echo "docker rm --force '$NAME'"
docker-verbose rm --force "$NAME"
