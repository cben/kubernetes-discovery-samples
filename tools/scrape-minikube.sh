#!/bin/bash
# Usage: scrape-minikube.sh 0.28.0
#   Takes version *of minikube*, symlinks resulting kubernetes version afterwards

set -e -u -o pipefail

cd "$(dirname "$(dirname "$0")")"  # run from root of repo.

VERSION="v$1"
MINIKUBE="tools/minikube-$VERSION"

if ! [ -f "$MINIKUBE" ]; then
  echo "Downloading $MINIKUBE ..."
  curl --fail --location --output "$MINIKUBE".download https://storage.googleapis.com/minikube/releases/"$VERSION"/minikube-linux-amd64
  mv "$MINIKUBE"{.download,}
fi
chmod +x "$MINIKUBE"

"$MINIKUBE" start --vm-driver=none
IP="$("$MINIKUBE" ip)"

# We don't know kubernetes version yet
export DIR="minikube-$VERSION"
env URL="https://$IP:8443" WAIT_OK=healthz tools/scrape.sh --cert /home/bpaskinc/.minikube/apiserver.crt --key /home/bpaskinc/.minikube/apiserver.key

ln -s $DIR kubernetes-"$(jq --raw-output .gitVersion "$DIR"/version/index.json)"

echo
echo "# When done run:"
echo "$MINIKUBE stop"
#"$MINIKUBE" stop
