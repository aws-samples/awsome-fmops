SHELL := /bin/bash

default: help

help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

install-awscli: # Install AWS CLI
	bash scripts/install-awscli.sh

install-kubectl: # Install kubectl command that matches to the cluster version
	bash scripts/install-kubectl.sh

install-terraform: # Install terraform CLI
	bash scripts/install-terraform.sh

deploy: # Deploy aws resources and kubernetes resources
	bash scripts/deploy-infra.sh

port-forward:
	kubectl port-forward service/$(SERVICE_NAME) 8080:8080

destroy: # Destroy aws recources and kubernetes resources
	bash scripts/destroy-infra.sh


