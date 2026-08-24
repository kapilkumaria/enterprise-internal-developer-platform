variable "project_name" {
  description = "Project identifier used for naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "github_owner" {
  description = "GitHub account or organization that owns Golden Path service repositories."
  type        = string
}

variable "github_owner_id" {
  description = "Immutable numeric GitHub account ID used in GitHub OIDC subject claims."
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the Golden Path CI role."
  type        = string
  default     = "main"
}

variable "ecr_repository_arn_pattern" {
  description = "ARN pattern restricting CI access to the approved Golden Path ECR repository namespace."
  type        = string
}
