#!/usr/bin/env bash
set -euxo pipefail

cd terraform
terraform destroy -auto-approve