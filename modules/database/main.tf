# =============================================================================
# Database Module - Migrated Databases from vCenter
# =============================================================================
# This module represents databases migrated from VMware vCenter to AWS RDS
# using AWS Database Migration Service (DMS)
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# RDS Subnet Group
# -----------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name        = "${local.name_prefix}-db-subnet-group"
  description = "Database subnet group for migrated databases"
  subnet_ids  = var.database_subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

# -----------------------------------------------------------------------------
# RDS Parameter Group
# -----------------------------------------------------------------------------
resource "aws_db_parameter_group" "mysql" {
  count = var.create_mysql ? 1 : 0

  name        = "${local.name_prefix}-mysql-params"
  family      = "mysql8.0"
  description = "Parameter group for migrated MySQL databases"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = var.tags
}

resource "aws_db_parameter_group" "postgres" {
  count = var.create_postgres ? 1 : 0

  name        = "${local.name_prefix}-postgres-params"
  family      = "postgres15"
  description = "Parameter group for migrated PostgreSQL databases"

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Security Group for RDS
# -----------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.app_security_group_ids
  }

  ingress {
    description     = "PostgreSQL from app servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.app_security_group_ids
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-rds-sg"
  })
}

# -----------------------------------------------------------------------------
# RDS MySQL Instance (Migrated from vCenter)
# -----------------------------------------------------------------------------
resource "aws_db_instance" "mysql" {
  count = var.create_mysql ? 1 : 0

  identifier = "${local.name_prefix}-mysql"

  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.mysql_instance_class
  allocated_storage    = var.mysql_allocated_storage
  max_allocated_storage = var.mysql_max_allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = var.mysql_database_name
  username = var.mysql_username
  password = var.mysql_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.mysql[0].name

  multi_az               = var.environment == "prod" ? true : false
  publicly_accessible    = false
  deletion_protection    = var.environment == "prod" ? true : false
  skip_final_snapshot    = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "${local.name_prefix}-mysql-final" : null

  backup_retention_period = var.environment == "prod" ? 30 : 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn         = aws_iam_role.rds_monitoring.arn

  enabled_cloudwatch_logs_exports = ["error", "slowquery", "general"]

  tags = merge(var.tags, {
    Name            = "${local.name_prefix}-mysql"
    MigrationSource = "vCenter"
    SourceDB        = var.vcenter_source_databases["mysql"].name
  })
}

# -----------------------------------------------------------------------------
# RDS PostgreSQL Instance (Migrated from vCenter)
# -----------------------------------------------------------------------------
resource "aws_db_instance" "postgres" {
  count = var.create_postgres ? 1 : 0

  identifier = "${local.name_prefix}-postgres"

  engine               = "postgres"
  engine_version       = "15"
  instance_class       = var.postgres_instance_class
  allocated_storage    = var.postgres_allocated_storage
  max_allocated_storage = var.postgres_max_allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = var.postgres_database_name
  username = var.postgres_username
  password = var.postgres_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.postgres[0].name

  multi_az               = var.environment == "prod" ? true : false
  publicly_accessible    = false
  deletion_protection    = var.environment == "prod" ? true : false
  skip_final_snapshot    = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "${local.name_prefix}-postgres-final" : null

  backup_retention_period = var.environment == "prod" ? 30 : 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn         = aws_iam_role.rds_monitoring.arn

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(var.tags, {
    Name            = "${local.name_prefix}-postgres"
    MigrationSource = "vCenter"
    SourceDB        = var.vcenter_source_databases["postgres"].name
  })
}

# -----------------------------------------------------------------------------
# IAM Role for RDS Enhanced Monitoring
# -----------------------------------------------------------------------------
resource "aws_iam_role" "rds_monitoring" {
  name = "${local.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# -----------------------------------------------------------------------------
# ElastiCache Redis (Migrated from on-prem Redis)
# -----------------------------------------------------------------------------
resource "aws_elasticache_subnet_group" "main" {
  count = var.create_redis ? 1 : 0

  name       = "${local.name_prefix}-redis-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = var.tags
}

resource "aws_security_group" "redis" {
  count = var.create_redis ? 1 : 0

  name        = "${local.name_prefix}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from app servers"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.app_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redis-sg"
  })
}

resource "aws_elasticache_replication_group" "redis" {
  count = var.create_redis ? 1 : 0

  replication_group_id = "${local.name_prefix}-redis"
  description          = "Redis cluster migrated from vCenter"

  node_type            = var.redis_node_type
  num_cache_clusters   = var.environment == "prod" ? 2 : 1
  port                 = 6379
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"

  subnet_group_name  = aws_elasticache_subnet_group.main[0].name
  security_group_ids = [aws_security_group.redis[0].id]

  automatic_failover_enabled = var.environment == "prod" ? true : false
  multi_az_enabled          = var.environment == "prod" ? true : false
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  snapshot_retention_limit = var.environment == "prod" ? 7 : 1
  snapshot_window         = "03:00-05:00"
  maintenance_window      = "mon:05:00-mon:07:00"

  tags = merge(var.tags, {
    Name            = "${local.name_prefix}-redis"
    MigrationSource = "vCenter"
  })
}
