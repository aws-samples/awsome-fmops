#!/usr/bin/env bash
set -euxo pipefail

cd terraform 
terraform init
terraform apply -auto-approve
cd .. 
bash scripts/retrieve-variables-from-tf.sh