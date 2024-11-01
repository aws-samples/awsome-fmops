# Adopted from https://github.com/aws-samples/karpenter-blueprints/blob/429be198cde909d8a6e979c845150167ff295c0a/cluster/terraform/main.tf
## THIS TO AUTHENTICATE TO ECR, DON'T CHANGE IT
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

data "aws_availability_zones" "available" {}

locals {
  name            = "awsome-fmops"
  cluster_version = "1.29"
  region          = var.region
  node_group_name = "managed-ondemand"

  node_iam_role_name = module.eks_blueprints_addons.karpenter.node_iam_role_name

  vpc_cidr = "10.0.0.0/16"
  # NOTE: You might need to change this less number of AZs depending on the region you're deploying to
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    blueprint = local.name
  }
}

################################################################################
# Cluster
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.3"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }

    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cloudwatch_log_group              = false
  create_cluster_security_group            = false
  create_node_security_group               = false
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  enable_efa_support                  = true

  eks_managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large", "m5.large", "m5a.large", "m5ad.large", "m5d.large", "t2.large", "t3.large", "t3a.large"]

      create_security_group = false

      subnet_ids   = module.vpc.private_subnets
      max_size     = 2
      desired_size = 2
      min_size     = 2

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      labels = {
        intent = "control-apps"
      }
    }
    gpu = {
      node_group_name = "managed-p5"
      instance_types = ["p5.48xlarge"]

      create_security_group = false
      subnet_ids   = [module.vpc.private_subnets[0]]
      max_size = 4
      desired_size = 4
      min_size = 4
      # Comment out this block to use on-demand instances without ODCR
      capacity_reservation_specification = {
        capacity_reservation_target = {
          capacity_reservation_id = "cr-03d3df2e13babf2ae" 
        }
      }
      ebs_optimized     = true
      enable_monitoring = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 1024
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
      # The P Series can leverage EFA devices, below we attach EFA interfaces to all of the available slots to the instance
      # we assign the host interface device_index=0, and all other interfaces device_index=1
      #   p5.48xlarge has 32 network card indexes so the range should be 31, we'll create net interfaces 0-31
      #   p4 instances have 4 network card indexes so the range should be 4, we'll create Net interfaces 0-3
      network_interfaces = [
        for i in range(32) : {
          associate_public_ip_address = false
          delete_on_termination       = true
          device_index                = i == 0 ? 0 : 1
          network_card_index          = i
          interface_type              = "efa"
        }
      ]
      # add `--local-disks raid0` to use the NVMe devices underneath the Pods, kubelet, containerd, and logs: https://github.com/awslabs/amazon-eks-ami/pull/1171
      bootstrap_extra_args = "--local-disks raid0"
      taints = {
        gpu = {
          key      = "nvidia.com/gpu"
          effect   = "NO_SCHEDULE"
          operator = "EXISTS"
        }
      }      
    }
  }

  tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16.1"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  create_delay_dependencies = [for prof in module.eks.eks_managed_node_groups : prof.node_group_arn]

  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true

  eks_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }

  enable_aws_for_fluentbit = true
  aws_for_fluentbit = {
    set = [
      {
        name  = "cloudWatchLogs.region"
        value = var.region
      }
    ]
  }

  enable_karpenter = true

  karpenter = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
  }
  karpenter_enable_spot_termination          = true
  karpenter_enable_instance_profile_creation = true
  karpenter_node = {
    iam_role_use_name_prefix = false
  }

  tags = local.tags
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.37.1"

  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

module "aws-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks_blueprints_addons.karpenter.node_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.6.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
    "karpenter.sh/discovery"              = local.name
  }

  tags = local.tags
}


module "eks_data_addons" {
  source                          = "aws-ia/eks-data-addons/aws"
  version                         = "~> 1.0" # ensure to update this to the latest/desired version
  oidc_provider_arn               = module.eks.oidc_provider_arn
  enable_nvidia_device_plugin     = true
  enable_aws_neuron_device_plugin = true
}

resource "aws_ecr_repository" "awsome-fmops" {
  name                 = "awsome-fmops"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
}


#resource "kubectl_manifest" "gpu-default-nodepool" {
#  yaml_body = file("nodepools/gpu-nodepool.yaml")
#}
#
#resource "kubectl_manifest" "gpu-default-nodeclass" {
#  yaml_body = file("nodepools/gpu-nodeclass.yaml")
#}
#
#resource "kubectl_manifest" "neuron-default-nodepool" {
#  yaml_body = file("nodepools/neuron-nodepool.yaml")
#}
#
#resource "kubectl_manifest" "neuron-default-nodeclass" {
#  yaml_body = file("nodepools/neuron-nodeclass.yaml")
#}

#resource "helm_release" "kube-prometheus-stack" {
#  name       = "prometheus"
#  create_namespace = true
#  repository = "https://prometheus-community.github.io/helm-charts"
#  chart      = "kube-prometheus-stack"
#  namespace  = "prometheus"
#  values = [
#    file("helm-values/kube-prometheus-stack-values.yaml")
#  ]
#  depends_on = [ module.eks ]
#}
#