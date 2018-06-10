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
  echo -n "Scraping  $DIR/$1/index.json  <--  $URL/$1  ...  "
  # "./" prefix allows scrape "" to work.
  mkdir -p "./$1"

  set +e
  # --fail prevents creating index.json on errors like 403 Forbidden.
  # This is inconvenient, but more correct (?) than creating the file which
  # would then be served 200 OK from GitHub Pages
  curl --insecure --location "$URL/$1" --fail --verbose -o "./$1/index.json" 2> "./$1/curl-verbose.txt"
  status=$?
  set -e

  echo "$(grep '< HTTP' "./$1/curl-verbose.txt" || tail -n1 "./$1/curl-verbose.txt")"
  return $status
}

echo "Waiting for server..."
while ! scrape ""; do
  sleep 1
done

scrape version
scrape version/openshift

echo "Iterating .paths from /"
for PTH in $(jq --raw-output '.paths[] | ltrimstr("/")' index.json); do
  scrape "$PTH" || echo SKIPPED
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
