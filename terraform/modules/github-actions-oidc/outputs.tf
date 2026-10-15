output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions IAM OIDC provider."
  value       = data.aws_iam_openid_connect_provider.github_actions.arn
}

output "github_actions_role_name" {
  description = "Name of the IAM role assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.name
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_ecr_policy_arn" {
  description = "ARN of the ECR policy attached to the GitHub Actions role."
  value       = aws_iam_policy.github_actions_ecr.arn
}
