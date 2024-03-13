# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region  = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  cidr = var.vpc_cidr_group

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks,0,var.private_subnets_number)
  public_subnets  = slice(var.public_subnet_cidr_blocks,0,var.public_subnets_number)

  enable_nat_gateway = var.nat_gateway
  enable_vpn_gateway = var.vpc_gateway

  tags = {
    project     = var.resource_tags["project"],
    environment = var.resource_tags["environment"]
  }
}

module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "4.17.0"

  name        = "web-sg-project-alpha-dev"
  description = "Security group for web-servers with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks

  tags = {
    project     = var.resource_tags["project"],
    environment = var.resource_tags["environment"]
  }
}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "4.17.0"

  name        = "lb-sg-project-alpha-dev"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
  project     = var.resource_tags["project"],
  environment = var.resource_tags["environment"]
  }
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "4.0.1"

  # Ensure load balancer name is unique
  name = "lb-${random_string.lb_id.result}-project-alpha-dev"

  internal = false

  security_groups = [module.lb_security_group.security_group_id]
  subnets         = module.vpc.public_subnets

  number_of_instances = length(module.ec2_instances.instance_ids)
  instances           = module.ec2_instances.instance_ids

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }

  tags = {
    project     = var.resource_tags["project"],
    environment = var.resource_tags["environment"]
  }
}

module "ec2_instances" {
  source = "./modules/aws-instance"

  depends_on = [module.vpc]

  instance_count     = var.number_of_instances
  instance_type      = var.instance_type
  subnet_ids         = module.vpc.private_subnets[*]
  security_group_ids = [module.app_security_group.security_group_id]

  tags = {
    project     = var.resource_tags["project"],
    environment = var.resource_tags["environment"]
  }
}
