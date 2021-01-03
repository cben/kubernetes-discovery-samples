#!/bin/bash
# Usage: scrape-k0s.sh 0.8.0
# Available versions: https://hub.docker.com/r/k0sproject/k0s/tags/

set -e -u -o pipefail

cd "$(dirname "$(dirname "$0")")"  # run from root of repo.

VERSION="v$1"

NAME="k0s-controller-$VERSION"

docker-verbose () {
  echo sudo docker "$@"
  sudo docker "$@"
}

# This may fail with "Conflict. The container name "/k0s-v1.2.0" is already in use by container ..."
if docker ps --all | grep "$NAME"; then
  docker-verbose start "$NAME"
else
  docker-verbose run --detach --name "$NAME" --hostname controller --privileged -v /var/lib/k0s -p 6443:6443 "k0sproject/k0s:$VERSION"
fi

export URL=https://localhost:6443
export DIR=k0s-"$VERSION"

until curl --insecure --fail "$URL/healthz" | grep ok; do
  sleep 1
done

# TODO: extract kubeconfig auth unpacking into helper script.

# Absolute path because scrape.sh changes in $DIR.
# Here and not under $DIR because scrape.sh wipes it clean.
AUTHDIR="$PWD/auth.tmp"
mkdir --parents "$AUTHDIR"

docker exec "$NAME" cat /var/lib/k0s/pki/admin.conf > "$AUTHDIR/kubeconfig"
cat "$AUTHDIR/kubeconfig" | yq '.clusters[0].cluster["certificate-authority-data"]' --raw-output | base64 --decode > "$AUTHDIR/server-ca"
cat "$AUTHDIR/kubeconfig" | yq '.users[0].user["client-certificate-data"]' --raw-output | base64 --decode > "$AUTHDIR/client-cert"
cat "$AUTHDIR/kubeconfig" | yq '.users[0].user["client-key-data"]' --raw-output | base64 --decode > "$AUTHDIR/client-key"
cat "$AUTHDIR/client-key" "$AUTHDIR/client-cert" > "$AUTHDIR/client-key+cert"

env WAIT_OKS="healthz" tools/scrape.sh --cacert "$AUTHDIR/server-ca" --cert "$AUTHDIR/client-cert" --key "$AUTHDIR/client-key"

echo
#docker ps --all --filter=name="$NAME"
#echo "# When done run:"
#echo "docker rm --force '$NAME'"
docker-verbose rm --force "$NAME"
