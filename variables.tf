# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Variable declarations
variable "aws_region" {
    description = "AWS region"
    type        = string
    default     = "us-west-2"
}

variable "vpc_cidr_group" {
    description = "CIDR block for VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "number_of_instances" {
    description = "the number of instances for provision"
    type        = number
}

variable "instance_type" {
    description = "type of AWS instance"
    type        = string
}

variable "vpc_gateway" {
    description = "with or without vpc enabled"
    type        = bool
    default     = false
}

variable "nat_gateway" {
    description = "with or without nat enabled"
    type        = bool
    default     = true
}

variable "public_subnets_number" {
    description = "Number of public subnets"
    type        = number
    default     = 2
}

variable "private_subnets_number" {
    description = "Number of private subnets"
    type        = number
    default     = 2
}

variable "private_subnet_cidr_blocks" {
    description = "CIDR blocks for private subnets"
    type        = list(string)
    default    = [
        "10.0.101.0/24", 
        "10.0.102.0/24",
        "10.0.103.0/24", 
        "10.0.104.0/24",
        "10.0.105.0/24",
        "10.0.106.0/24"
    ]
}

variable "public_subnet_cidr_blocks" {
    description = "CIDR blocks for private subnets"
    type        = list(string)
    default    = [
        "10.0.1.0/24", 
        "10.0.2.0/24",
        "10.0.3.0/24", 
        "10.0.4.0/24",
        "10.0.5.0/24",
        "10.0.6.0/24"
    ]
}

variable "resource_tags" {
    description = "Tags to set for all resources"
    type        = map(string)
    /*default     = {
      project     = "project-alpha"
      environment = "dev"
    }*/
}