#!/usr/bin/env bash
set -euxo pipefail

. .env
KUBECTL_VERSION="v${CLUSTER_VERSION}.0"
echo "Install kubectl {$KUBECTL_VERSION}"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client