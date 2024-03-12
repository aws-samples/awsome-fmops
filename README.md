# Reference Architecture: Machine Learning Inference with KServe and Karpenter on Amazon EKS
## Overview
KServe offers a standard Kubernetes-based Model Inference Platform for scalable use-cases. Complementing it, Karpenter provides swift, simplified compute provisioning, optimally leveraging cloud resources. This synergy offers a unique opportunity to exploit Spot instances, enhancing cost efficiency. This reference architecture illustrates the mechanics of these technologies and demonstrate their combined power in enabling efficient serverless ML deployments.

All the infrastructure will be constructed through Terraform.
In addition to the infrastructure this repository contains tutorials utilizing different compute (CPU/GPU/Inferentia) in `tutorials` directory.

* Kaprenter autoscaling
* KServe inference example
* Benchmarking KServe Inference service

## Pre-requisites
The following tools are required to work with this repository:
* make
* aws-cli
* terraform
* kubectl

`make` comamnd can be downloaded from https://www.gnu.org/software/make/ or package manager of your choice.
You can install the rest of the tools with `make install-awscli` , `make install-terraform`, `make install-kubectl`.


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

