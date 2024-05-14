provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = "karpenter-blueprints"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "karpenter-blueprints"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks_data_addons" {
  source                          = "aws-ia/eks-data-addons/aws"
  version                         = "~> 1.0" # ensure to update this to the latest/desired version
  oidc_provider_arn               = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
  enable_nvidia_device_plugin     = true
  enable_aws_neuron_device_plugin = true
}

resource "helm_release" "kserve_crd" {
  name       = "kserve-crd"
  repository = "oci://ghcr.io/kserve/charts"
  chart      = "kserve-crd"
  version    = "v0.12.0"
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.14.5"
  timeout          = 600
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "kserve" {
  name             = "kserve"
  namespace        = "kserve"
  create_namespace = true
  repository       = "oci://ghcr.io/kserve/charts"
  chart            = "kserve"
  version          = "v0.12.0"

  depends_on = [helm_release.cert-manager]

}

resource "kubectl_manifest" "gpu-default-nodepool" {
  yaml_body = file("nodepools/gpu-nodepool.yaml")
}

resource "kubectl_manifest" "gpu-default-nodeclass" {
  yaml_body = file("nodepools/gpu-nodeclass.yaml")
}

resource "kubectl_manifest" "neuron-default-nodepool" {
  yaml_body = file("nodepools/neuron-nodepool.yaml")
}

resource "kubectl_manifest" "neuron-default-nodeclass" {
  yaml_body = file("nodepools/neuron-nodeclass.yaml")
}