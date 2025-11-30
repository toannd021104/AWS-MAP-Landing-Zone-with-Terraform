# =============================================================================
# Database Module - Outputs
# =============================================================================

output "mysql_endpoint" {
  description = "MySQL RDS endpoint"
  value       = var.create_mysql ? aws_db_instance.mysql[0].endpoint : null
}

output "mysql_address" {
  description = "MySQL RDS address"
  value       = var.create_mysql ? aws_db_instance.mysql[0].address : null
}

output "mysql_port" {
  description = "MySQL RDS port"
  value       = var.create_mysql ? aws_db_instance.mysql[0].port : null
}

output "mysql_arn" {
  description = "MySQL RDS ARN"
  value       = var.create_mysql ? aws_db_instance.mysql[0].arn : null
}

output "postgres_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = var.create_postgres ? aws_db_instance.postgres[0].endpoint : null
}

output "postgres_address" {
  description = "PostgreSQL RDS address"
  value       = var.create_postgres ? aws_db_instance.postgres[0].address : null
}

output "postgres_port" {
  description = "PostgreSQL RDS port"
  value       = var.create_postgres ? aws_db_instance.postgres[0].port : null
}

output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = var.create_redis ? aws_elasticache_replication_group.redis[0].primary_endpoint_address : null
}

output "redis_port" {
  description = "Redis port"
  value       = var.create_redis ? 6379 : null
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = var.create_redis ? aws_security_group.redis[0].id : null
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = aws_db_subnet_group.main.name
}
