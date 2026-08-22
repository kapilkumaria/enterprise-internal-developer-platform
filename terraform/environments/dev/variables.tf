variable "aws_region" {
  description = "AWS region used by the platform."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used for resource names and tags."
  type        = string
  default     = "enterprise-idp"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the platform VPC."
  type        = string
  default     = "10.50.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the platform."
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)

  default = [
    "10.50.1.0/24",
    "10.50.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)

  default = [
    "10.50.11.0/24",
    "10.50.12.0/24"
  ]
}
