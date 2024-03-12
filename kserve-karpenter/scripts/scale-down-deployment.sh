#!/usr/bin/env bash
set -euxo pipefail
. .env

kubectl delete deployment inflate
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller