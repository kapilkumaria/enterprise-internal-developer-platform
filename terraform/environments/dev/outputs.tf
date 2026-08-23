output "vpc_id" {
  description = "ID of the platform VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = module.networking.nat_gateway_id
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS worker-node IAM role."
  value       = module.iam.eks_node_role_arn
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS API server."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster."
  value       = module.eks.cluster_version
}

output "eks_node_group_name" {
  description = "Name of the EKS managed node group."
  value       = module.eks.node_group_name
}

output "eks_cluster_security_group_id" {
  description = "Security group used by the EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "backstage_ecr_repository_name" {
  description = "Name of the Backstage ECR repository."
  value       = module.ecr_backstage.repository_name
}

output "backstage_ecr_repository_url" {
  description = "URL of the Backstage ECR repository."
  value       = module.ecr_backstage.repository_url
}

output "backstage_db_endpoint" {
  description = "Backstage PostgreSQL endpoint."
  value       = module.rds.db_endpoint
}

output "backstage_db_port" {
  description = "Backstage PostgreSQL port."
  value       = module.rds.db_port
}

output "backstage_db_name" {
  description = "Backstage PostgreSQL database name."
  value       = module.rds.db_name
}

output "backstage_db_secret_arn" {
  description = "Secrets Manager ARN containing Backstage database credentials."
  value       = module.rds.master_user_secret_arn
}

output "golden_path_ecr_repository_name" {
  description = "Name of the Golden Path application ECR repository."
  value       = module.ecr_golden_path_demo.repository_name
}

output "golden_path_ecr_repository_url" {
  description = "URL of the Golden Path application ECR repository."
  value       = module.ecr_golden_path_demo.repository_url
}

output "golden_path_ecr_repository_arn" {
  description = "ARN of the Golden Path application ECR repository."
  value       = module.ecr_golden_path_demo.repository_arn
}

output "github_actions_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = module.github_actions_oidc.oidc_provider_arn
}

output "github_actions_role_name" {
  description = "Name of the Golden Path GitHub Actions IAM role."
  value       = module.github_actions_oidc.github_actions_role_name
}

output "github_actions_role_arn" {
  description = "ARN of the Golden Path GitHub Actions IAM role."
  value       = module.github_actions_oidc.github_actions_role_arn
}
