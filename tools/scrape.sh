#!/bin/bash
# Usage: env URL=... DIR=... scrape.sh

set -e -u -o pipefail

rm -rf "$DIR"
mkdir -p --verbose "$DIR"
cd "$DIR"

scrape () {
  # Usage: scrape http_path [curl_options...]
  PTH="$1"
  shift

  echo -n "Scraping  $DIR/$PTH/index.json  <--  $URL/$PTH  ...  "
  # "./" prefix allows scrape "" to work.
  mkdir -p "./$PTH"

  set +e
  LC_ALL=en_US.utf8 curl --insecure --location "$URL/$PTH" --output "./$PTH/index.json" --dump-header "./$PTH/headers.txt" --verbose --silent --show-error "$@" 2> "./$PTH/curl-verbose.txt"
  status=$?
  set -e

  echo "$(grep '< HTTP' "./$PTH/curl-verbose.txt" || tail -n1 "./$PTH/curl-verbose.txt")"
  return $status
}

echo "Waiting for server..."
until scrape healthz/ready --fail && grep ok ./healthz/ready/index.json; do
  sleep 1
done

scrape ""
scrape version
scrape version/openshift

echo "Iterating .paths from /"
for PTH in $(jq --raw-output '.paths[] | ltrimstr("/")' index.json); do
  scrape "$PTH"
done

# TODO oapi/ is specific to openshift.
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
