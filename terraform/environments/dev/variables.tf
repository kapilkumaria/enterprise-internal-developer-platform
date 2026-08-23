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

variable "kubernetes_version" {
  description = "Kubernetes version used by the EKS cluster."
  type        = string
  default     = "1.36"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types used by the EKS managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "github_owner" {
  description = "GitHub account or organization used by the Internal Developer Platform."
  type        = string
  default     = "kapilkumaria"
}

variable "golden_path_repository" {
  description = "Golden Path validation repository permitted to use the GitHub Actions AWS role."
  type        = string
  default     = "idp-golden-path-demo"
}

variable "github_owner_id" {
  description = "Immutable numeric GitHub account ID used by GitHub OIDC."
  type        = string
  default     = "42500918"
}

variable "golden_path_repository_id" {
  description = "Immutable numeric GitHub repository ID for the Golden Path validation service."
  type        = string
  default     = "1344141938"
}
