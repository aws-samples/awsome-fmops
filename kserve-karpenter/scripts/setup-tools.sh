#!/usr/bin/env bash
set -euxo pipefail

echo "Install AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o -q awscliv2.zip
sudo ./aws/install --update
rm -r ./aws
rm -r awscliv2.zip
aws --version

KUBECTL_VERSION="v1.25.0"
echo "Install kubectl {$KUBECTL_VERSION}"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client


# Enable kubectl bash_completion
kubectl completion bash >>  ~/.bash_completion
. ~/.bash_completion

# Install Terraform
TERRAFORM_VERSION=1.4.5
curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform.zip"
unzip -o -q terraform.zip
sudo install -o root -g root -m 0755 terraform /usr/local/bin/terraform
rm terraform.zip
rm terraform
terraform -install-autocomplete
terraform --version

# Install eks node viewer
wget https://go.dev/dl/go1.20.3.linux-amd64.tar.gz
rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
/usr/local/go/bin install github.com/awslabs/eks-node-viewer/cmd/eks-node-viewer@latest
 
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
# If the role has already been successfully created, you will see:
# An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.
