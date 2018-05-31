#!/bin/bash

set -e

VERSION="v$1"

DIR="$(dirname "$(dirname "$0")")"/openshift-origin-"$VERSION"

NAME="origin-$VERSION" 

# This may fail with "Conflict. The container name "/origin-v1.2.0" is already in use by container ..."
docker ps | grep "$NAME" ||
sudo docker run -d --name "$NAME" \
        --privileged --pid=host --net=host \
        -v /:/rootfs:ro -v /var/run:/var/run:rw -v /sys:/sys -v /var/lib/docker:/var/lib/docker:rw \
        -v /var/lib/origin/openshift.local.volumes:/var/lib/origin/openshift.local.volumes \
        "docker.io/openshift/origin:$VERSION" start

mkdir -p "$DIR"
cd "$DIR"

while ! curl --insecure https://localhost:8443 -o .json; do
  sleep 1
done

for GROUP in api oapi; do
  curl --insecure "https://localhost:8443/$GROUP" -o "$GROUP.json"
  mkdir -p "$GROUP"
  for APIVER in $(jq --raw-output '.versions[]' "$GROUP.json"); do
    curl --insecure "https://localhost:8443/$GROUP/$APIVER" -o "$GROUP"/"$APIVER".json
  done
done

curl --insecure "https://localhost:8443/apis" -o apis.json
for GROUP in $(jq --raw-output '.groups[].name' apis.json); do
  mkdir -p "apis/$GROUP"
  curl --insecure "https://localhost:8443/apis/$GROUP" -o "apis/$GROUP.json"
  for APIVER in $(jq --raw-output '.versions[].version' "apis/$GROUP.json"); do
    curl --insecure "https://localhost:8443/$GROUP/$APIVER" -o "apis/$GROUP"/"$APIVER".json
  done
done

find -type f

docker stop "$NAME"
