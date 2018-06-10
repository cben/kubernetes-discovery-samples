#!/bin/bash

set -e -u -o pipefail

VERSION="v$1"

DIR="$(dirname "$(dirname "$0")")"/openshift-origin-"$VERSION"

NAME="origin-$VERSION"

# This may fail with "Conflict. The container name "/origin-v1.2.0" is already in use by container ..."
if docker ps -a | grep "$NAME"; then
  docker start "$NAME"
else
  sudo docker run -d --name "$NAME" \
       --privileged --pid=host --net=host \
       -v /:/rootfs:ro -v /var/run:/var/run:rw -v /sys:/sys -v /var/lib/docker:/var/lib/docker:rw \
       -v /var/lib/origin/openshift.local.volumes:/var/lib/origin/openshift.local.volumes \
       "docker.io/openshift/origin:$VERSION" start
fi

rm -rf "$DIR"
mkdir -p "$DIR"
cd "$DIR"

URL=https://localhost:8443

scrape () {
  # Usage: scrape http_path [curl_options...]
  PTH="$1"
  shift

  echo -n "Scraping  $DIR/$PTH/index.json  <--  $URL/$PTH  ...  "
  # "./" prefix allows scrape "" to work.
  mkdir -p "./$PTH"

  set +e
  curl --insecure --location "$URL/$PTH" -o "./$PTH/index.json" --verbose "$@" 2> "./$PTH/curl-verbose.txt"
  status=$?
  set -e

  echo "$(grep '< HTTP' "./$PTH/curl-verbose.txt" || tail -n1 "./$PTH/curl-verbose.txt")"
  return $status
}

echo "Waiting for server..."
until scrape "" --fail; do
  sleep 1
done

scrape version
scrape version/openshift

echo "Iterating .paths from /"
for PTH in $(jq --raw-output '.paths[] | ltrimstr("/")' index.json); do
  scrape "$PTH"
done

echo "Iterating .versions from api/ and oapi/"
for GROUP in api oapi; do
  for APIVER in $(jq --raw-output '.versions[]' "$GROUP/index.json"); do
    scrape "$GROUP/$APIVER"
  done
done

echo "Iterating .groups from apis/"
scrape "apis"
for GROUP in $(jq --raw-output '.groups[].name' apis/index.json); do
  scrape "apis/$GROUP"
  for APIVER in $(jq --raw-output '.versions[].version' "apis/$GROUP/index.json"); do
    scrape "apis/$GROUP/$APIVER"
  done
done

#docker stop "$NAME"

echo
echo "# When done run:"
echo "docker rm -f '$NAME'"
