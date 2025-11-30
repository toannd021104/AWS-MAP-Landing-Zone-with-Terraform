# =============================================================================
# Database Module - Variables
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs"
  type        = list(string)
}

variable "app_security_group_ids" {
  description = "Application security group IDs allowed to access databases"
  type        = list(string)
}

# -----------------------------------------------------------------------------
# MySQL Configuration
# -----------------------------------------------------------------------------
variable "create_mysql" {
  description = "Create MySQL RDS instance"
  type        = bool
  default     = true
}

variable "mysql_instance_class" {
  description = "Instance class for MySQL"
  type        = string
  default     = "db.t3.medium"
}

variable "mysql_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 100
}

variable "mysql_max_allocated_storage" {
  description = "Max allocated storage for autoscaling"
  type        = number
  default     = 500
}

variable "mysql_database_name" {
  description = "MySQL database name"
  type        = string
  default     = "appdb"
}

variable "mysql_username" {
  description = "MySQL master username"
  type        = string
  default     = "admin"
}

variable "mysql_password" {
  description = "MySQL master password"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# PostgreSQL Configuration
# -----------------------------------------------------------------------------
variable "create_postgres" {
  description = "Create PostgreSQL RDS instance"
  type        = bool
  default     = false
}

variable "postgres_instance_class" {
  description = "Instance class for PostgreSQL"
  type        = string
  default     = "db.t3.medium"
}

variable "postgres_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 100
}

variable "postgres_max_allocated_storage" {
  description = "Max allocated storage for autoscaling"
  type        = number
  default     = 500
}

variable "postgres_database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "appdb"
}

variable "postgres_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "admin"
}

variable "postgres_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
  default     = ""
}

# -----------------------------------------------------------------------------
# Redis Configuration
# -----------------------------------------------------------------------------
variable "create_redis" {
  description = "Create ElastiCache Redis"
  type        = bool
  default     = false
}

variable "redis_node_type" {
  description = "Node type for Redis"
  type        = string
  default     = "cache.t3.medium"
}

# -----------------------------------------------------------------------------
# vCenter Source Database Mapping
# -----------------------------------------------------------------------------
variable "vcenter_source_databases" {
  description = "Mapping of source databases from vCenter"
  type = map(object({
    name       = string
    type       = string
    ip_address = string
    port       = number
  }))
  default = {
    mysql = {
      name       = "vcenter-mysql-01"
      type       = "MySQL 5.7"
      ip_address = "192.168.1.50"
      port       = 3306
    }
    postgres = {
      name       = "vcenter-postgres-01"
      type       = "PostgreSQL 12"
      ip_address = "192.168.1.51"
      port       = 5432
    }
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
