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
