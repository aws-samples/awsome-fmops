#!/usr/bin/env bash
set -euxo pipefail
. .env
kubectl apply -f manifests/pause.yaml
kubectl scale deployment inflate --replicas 50
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller
