output "eks_cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS control plane."
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_cluster_role_name" {
  description = "Name of the IAM role used by the EKS control plane."
  value       = aws_iam_role.eks_cluster.name
}

output "eks_node_role_arn" {
  description = "ARN of the IAM role used by EKS worker nodes."
  value       = aws_iam_role.eks_node.arn
}

output "eks_node_role_name" {
  description = "Name of the IAM role used by EKS worker nodes."
  value       = aws_iam_role.eks_node.name
}

output "vpc_cni_role_arn" {
  description = "ARN of the IAM role used by the Amazon VPC CNI through EKS Pod Identity."
  value       = aws_iam_role.vpc_cni.arn
}

output "external_secrets_role_name" {
  description = "Name of the External Secrets Operator Pod Identity IAM role."
  value       = aws_iam_role.external_secrets.name
}

output "external_secrets_role_arn" {
  description = "ARN of the External Secrets Operator Pod Identity IAM role."
  value       = aws_iam_role.external_secrets.arn
}
