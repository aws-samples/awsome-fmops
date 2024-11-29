SHELL := /bin/bash
export TF_VAR_region := us-west-2

all: deploy
deploy:
	@echo "Building the infrastructure"
	&& terraform apply -target="module.vpc" -auto-approve \
	&& terraform apply -target="module.eks" -auto-approve \
	&& terraform apply --auto-approve \
	&& kubectl patch cm config-domain --patch '{"data":{"example.com":""}}' -n knative-serving
destroy:
	@echo "Destroying the infrastructure"
	kubectl delete --all nodeclaim \
	&& kubectl delete --all nodepool \
	&& kubectl delete --all ec2nodeclass \
	&& terraform destroy -target="module.eks" --auto-approve \
	&& terraform destroy -target="module.vpc" -auto-approve \
	&& terraform destroy --auto-approve