variable "project_name" {
  description = "Project identifier used for naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "github_owner" {
  description = "GitHub account or organization that owns the Golden Path repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the CI role."
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the CI role."
  type        = string
  default     = "main"
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository the GitHub Actions role may access."
  type        = string
}

variable "github_owner_id" {
  description = "Immutable numeric GitHub account ID used in the OIDC subject claim."
  type        = string
}

variable "github_repository_id" {
  description = "Immutable numeric GitHub repository ID used in the OIDC subject claim."
  type        = string
}
