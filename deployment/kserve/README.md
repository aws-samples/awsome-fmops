# Scalable FM Inference with KServe

This repository contains a reference architecture and test cases for Foundation Model inference with [KServe](https://github.com/kserve/kserve) on Amazon [EKS](https://aws.amazon.com/eks/), integrating [Karpenter](https://github.com/aws/karpenter-provider-aws) as cluster autoscaler.

KServe offers a standard Kubernetes-based Model Inference Platform for scalable use-cases. Complementing it, Karpenter provides swift, simplified compute provisioning, optimally leveraging cloud resources. This synergy offers a unique opportunity to exploit Spot instances, enhancing cost efficiency. This reference architecture illustrates the mechanics of these technologies and demonstrates their combined power in enabling efficient serverless ML deployments.

