SHELL := /bin/bash
export TF_VAR_region := us-west-2

all: build
build:
	@echo "Building the infrastructure"
	[ -d karpenter-blueprints ] || git clone https://github.com/aws-samples/karpenter-blueprints \
	&& pushd karpenter-blueprints/cluster/terraform \
	&& terraform init \
	&& terraform apply -auto-approve \
	&& terraform init \
	&& terraform apply -target="module.vpc" -auto-approve \
	&& terraform apply -target="module.eks" -auto-approve \
	&& terraform apply --auto-approve \
	&& popd \
	&& cd terraform \
	&& terraform init \
	&& terraform apply --auto-approve
destroy:
	@echo "Destroying the infrastructure"
	pushd terraform \
	&& kubectl delete --all nodeclaim \
	&& kubectl delete --all nodepool \
	&& kubectl delete --all ec2nodeclass \
	&& terraform destroy --auto-approve \
	&& popd \
	&& cd karpenter-blueprints/cluster/terraform \
	&& terraform destroy -target="module.eks_blueprints_addons" --auto-approve \
	&& terraform destroy -target="module.eks" --auto-approve \
	&& terraform destroy --auto-approve