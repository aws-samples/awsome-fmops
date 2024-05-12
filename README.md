# Foundation Model Inference Architectures with KServe on EKS

This repository contains a reference architecture and test cases for Foundation Model inference with [KServe](https://github.com/kserve/kserve) on Amazon [EKS](https://aws.amazon.com/eks/), integrating [Karpenter](https://github.com/aws/karpenter-provider-aws) as cluster autoscaler.

KServe offers a standard Kubernetes-based Model Inference Platform for scalable use-cases. Complementing it, Karpenter provides swift, simplified compute provisioning, optimally leveraging cloud resources. This synergy offers a unique opportunity to exploit Spot instances, enhancing cost efficiency. This reference architecture illustrates the mechanics of these technologies and demonstrates their combined power in enabling efficient serverless ML deployments.


## Deployment

This section guide you through how to deploy an EKS cluster and Kubernetes custom resources required.
This repository is built on top of [Karpenter Blueprints](https://github.com/aws-samples/karpenter-blueprints/tree/main). Please refer to the repository for the infrastructure set up or run `Make` to 


## Infrastructure validation



## Test cases

Once you have deploy


## License

This library is licensed under the MIT-0 License. See the LICENSE file.

