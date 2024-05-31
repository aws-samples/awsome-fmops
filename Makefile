SHELL := /bin/bash
export TF_VAR_region := us-west-2

all: deploy
deploy:
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
    && kubectl apply --filename https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-crds.yaml \
    && kubectl apply --filename https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-core.yaml \
    && kubectl apply --filename https://github.com/knative/net-istio/releases/download/knative-v1.13.1/release.yaml  \
	&& kubectl patch cm config-domain --patch '{"data":{"example.com":""}}' -n knative-serving
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