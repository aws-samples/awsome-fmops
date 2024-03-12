variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "karpenter-kserve"
}

variable "cluster_version" {
  default = "1.25"
}

variable "karpenter_version" {
  default = "v0.27.1"
}

variable "ingress_host" {
  default = "localhost"
}

variable "ingress_port" {
  default = "8080"
}
