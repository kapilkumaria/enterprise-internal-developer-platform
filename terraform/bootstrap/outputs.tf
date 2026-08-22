output "terraform_state_bucket_name" {
  description = "Name of the S3 bucket used to store Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_region" {
  description = "AWS region containing the Terraform state bucket."
  value       = var.aws_region
}
