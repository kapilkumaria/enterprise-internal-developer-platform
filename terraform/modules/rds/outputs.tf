output "db_instance_id" {
  description = "RDS PostgreSQL instance identifier."
  value       = aws_db_instance.postgres.id
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Backstage PostgreSQL database name."
  value       = aws_db_instance.postgres.db_name
}

output "db_security_group_id" {
  description = "Security group protecting the PostgreSQL instance."
  value       = aws_security_group.postgres.id
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials."
  value       = try(aws_db_instance.postgres.master_user_secret[0].secret_arn, null)
}
