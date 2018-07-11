#!/bin/bash
# Usage: scrape-minikube.sh MINIKUBE_VERSION KUBERNETES_VERSION
# minikube versions: https://github.com/kubernetes/minikube/tags

set -e -u -o pipefail

cd "$(dirname "$(dirname "$0")")"  # run from root of repo.

MINIKUBE_VERSION="v$1"
VERSION="v$2"
MINIKUBE="tools/minikube-$MINIKUBE_VERSION"

verbose () {
  echo "$@"
  "$@"
}

if ! [ -f "$MINIKUBE" ]; then
  echo "Downloading $MINIKUBE ..."
  curl --fail --location --output "$MINIKUBE".download https://storage.googleapis.com/minikube/releases/"$MINIKUBE_VERSION"/minikube-linux-amd64
  mv "$MINIKUBE"{.download,}
fi
chmod +x "$MINIKUBE"

verbose "$MINIKUBE" start --kubernetes-version="$VERSION" --cache-images

IP="$("$MINIKUBE" ip)"

export DIR="kubernetes-$VERSION"
env URL="https://$IP:8443" WAIT_OKS="healthz" tools/scrape.sh --cert /home/bpaskinc/.minikube/apiserver.crt --key /home/bpaskinc/.minikube/apiserver.key

echo
#echo "# When done run:"
#echo "$MINIKUBE delete"
verbose "$MINIKUBE" delete
