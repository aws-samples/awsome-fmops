#!/usr/bin/env bash
set -euxo pipefail

echo "Install AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o -q awscliv2.zip
sudo ./aws/install --update
rm -r ./aws
rm -r awscliv2.zip
aws --version