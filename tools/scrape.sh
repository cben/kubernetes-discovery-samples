#!/bin/bash
# Usage: env URL=... DIR=... WAIT_OKS='healthz healtz/ready' scrape.sh [curl_options...]

set -e -u -o pipefail

rm -rf "$DIR"
mkdir -p --verbose "$DIR"
cd "$DIR"

CURL_OPTIONS=("$@")

scrape () {
  # Usage: scrape http_path [curl_options...]
  PTH="$1"
  shift

  echo -n "Scraping  $DIR/$PTH/index.json  <--  $URL/$PTH  ...  "
  # "./" prefix allows scrape "" to work.
  mkdir -p "./$PTH"

  set +e
  LC_ALL=en_US.utf8 curl --insecure --location "$URL/$PTH" --output "./$PTH/index.json" --dump-header "./$PTH/headers.txt" --verbose --silent --show-error "${CURL_OPTIONS[@]}" "$@" 2> "./$PTH/curl-verbose.txt"
  status=$?
  set -e

  echo "$(grep '< HTTP' "./$PTH/curl-verbose.txt" || tail -n1 "./$PTH/curl-verbose.txt")"
  return $status
}

result () {
  # Usage: result http_path
  PTH="$1"
  cat ./$PTH/index.json
  echo  # the json typically has no trailing newline after last '}'
}

echo "Waiting for server..."
for WAIT_OK in $WAIT_OKS; do
  until scrape "$WAIT_OK" --fail && result "$WAIT_OK" | grep ok; do
    sleep 1
  done
done

# Obtain "paths" array.
scrape ""

# Scraping separately because old versions don't advertize /version (and /version/openshift) under "paths".
echo "====== Recorded version ====="
scrape "version"
result "version"
if scrape "version/openshift" --fail; then
  result "version/openshift"
fi

echo "Iterating .paths from /"
for PTH in $(result "" | jq --raw-output '.paths[] | ltrimstr("/")' | grep --invert-match -e '^/metrics' -e '^/logs'); do
  scrape "$PTH"
done

# TODO oapi/ is specific to openshift.
echo "Iterating .versions from api/ and oapi/"
for GROUP in api oapi; do
  for APIVER in $(result "$GROUP" | jq --raw-output '.versions[]'); do
    scrape "$GROUP/$APIVER"
  done
done

echo "Iterating .groups from apis/"
scrape "apis"
for GROUP in $(result "apis" | jq --raw-output '.groups[].name'); do
  scrape "apis/$GROUP"
  for APIVER in $(result "apis/$GROUP" | jq --raw-output '.versions[].version'); do
    scrape "apis/$GROUP/$APIVER"
  done
done
