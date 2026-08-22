variable "aws_region" {
  description = "AWS region used for the Terraform backend resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used for resource naming and tagging."
  type        = string
  default     = "enterprise-internal-developer-platform"
}

variable "state_bucket_prefix" {
  description = "Prefix used for the globally unique Terraform state S3 bucket."
  type        = string
  default     = "enterprise-idp-tfstate"
}
