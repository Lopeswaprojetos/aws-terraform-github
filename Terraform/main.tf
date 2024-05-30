terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = var.aws_vpc_name
  cidr = var.aws_cidr

  azs             = var.aws.vpc_azs
  private_subnets = var.aws_vpc_private_subnets
  public_subnets  = var.aws_vpc_public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = merge( var.aws_project_tags, {"kubernetes.io/cluster/${var.aws.eks_name}"= "shared"})

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.aws.eks_name}"= "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.aws.eks_name}"= "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
  }
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.10.0"

  cluster_name    = var.aws.eks_name
  cluster_version = var.aws.eks_version

  enable_cluster_creator_admin_permissions = true

  subnet_ids                     = module.vpc.private_subnets
  vpc_id                         = module.vpc.vpc_id
  cluster_endpoint_public_access = true
  eks_managed_node_groups = {
    default = {
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      instance_types = var.aws_eks_managed_node_groups_instance_types
    tags = var.aws_project_tags  
    }
  }

  tags = var.aws_project_tags
}

variable "aws_region" {
  description = "Região usada para criar os recursos da aws"
  type = string
  nullable = false
}

variable "aws_vpc_name" {
  description = "Colocar sempre a descriçao"
  type = string
  nullable = false
}

variable "aws_cidr" {
  description = "Colocar sempre a descriçao"
  type = string
  nullable = false
}

variable "aws_vpc_azs" {
  description = "Colocar sempre a descriçao"
  type = set(string)
  nullable = false
}

variable "aws_vpc_private_subnets" {
  description = "Colocar sempre a descriçao"
  type = set(string)
  nullable = false
}

variable "aws_vpc_public_subnets" {
  description = "Colocar sempre a descriçao"
  type = set(string)
  nullable = false
}

variable "aws_eks_name" {
  description = "Colocar sempre a descriçao"
  type = string
  nullable = false
}

variable "aws_eks_version" {
  description = "Colocar sempre a descriçao"
  type = string
  nullable = false
}

variable "aws_eks_managed_node_groups_instance_types" {
  description = "Colocar sempre a descriçao"
  type = set(string) 
  nullable = false
}

variable "aws_project_tags" {
  description = "Colocar sempre a descriçao"
  type = map(any)
  nullable = false
}