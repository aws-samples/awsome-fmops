provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = "karpenter-blueprints"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "karpenter-blueprints"  # Replace with your EKS cluster name
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

resource "helm_release" "kserve_crd" {
  name       = "kserve-crd"
  repository = "oci://ghcr.io/kserve/charts"
  chart      = "kserve-crd"
  version    = "v0.12.0"
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace = "cert-manager"
  create_namespace = true
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.5"
  timeout = 600
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "kserve" {
  name       = "kserve"
  namespace = "kserve"
  create_namespace = true
  repository = "oci://ghcr.io/kserve/charts"
  chart      = "kserve"
  version = "v0.12.0"

  depends_on = [helm_release.cert-manager]

}

resource "helm_release" "nvidia-divice-plugin" {
  name       = "nvdp"
  namespace = "nvidia-device-plugin"
  create_namespace = true
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  version = "0.15.0"
}

data "http" "k8s-neuron-device-plugin-yml" {
  url = "https://raw.githubusercontent.com/aws-neuron/aws-neuron-sdk/master/src/k8/k8s-neuron-device-plugin.yml"
}

resource "kubectl_manifest" "k8s-neuron-device-plugin" {
  yaml_body = data.http.k8s-neuron-device-plugin-yml.response_body
}

data "http" "k8s-neuron-device-plugin-rbac-yml" {
  url = "https://raw.githubusercontent.com/aws-neuron/aws-neuron-sdk/master/src/k8/k8s-neuron-device-plugin.yml"
}

resource "kubectl_manifest" "k8s-neuron-device-plugin-rbac" {
  yaml_body = data.http.k8s-neuron-device-plugin-rbac-yml.response_body
}