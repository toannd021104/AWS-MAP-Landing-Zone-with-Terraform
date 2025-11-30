# =============================================================================
# vCenter Migration Inventory - Fake Data for AWS MAP Demo
# =============================================================================
# This file contains the inventory of VMs to be migrated from VMware vCenter
# to AWS Landing Zone using AWS Application Migration Service (MGN)
# =============================================================================

# -----------------------------------------------------------------------------
# Source vCenter Environment
# -----------------------------------------------------------------------------
vcenter_config = {
  server     = "vcenter.company.local"
  datacenter = "DC-HCM"
  cluster    = "Cluster-Prod"
  datastore  = "SAN-01"
}

# -----------------------------------------------------------------------------
# Web Servers to Migrate
# -----------------------------------------------------------------------------
vcenter_source_vms = [
  {
    name       = "PROD-WEB-01"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.10"
    cpu        = 4
    memory_gb  = 8
    disk_gb    = 100
    os         = "CentOS 7"
    role       = "WebServer"
    apps       = ["nginx", "php-fpm"]
  },
  {
    name       = "PROD-WEB-02"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.11"
    cpu        = 4
    memory_gb  = 8
    disk_gb    = 100
    os         = "CentOS 7"
    role       = "WebServer"
    apps       = ["nginx", "php-fpm"]
  },
  {
    name       = "PROD-APP-01"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.20"
    cpu        = 8
    memory_gb  = 16
    disk_gb    = 200
    os         = "CentOS 7"
    role       = "AppServer"
    apps       = ["java", "tomcat"]
  },
  {
    name       = "PROD-APP-02"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.21"
    cpu        = 8
    memory_gb  = 16
    disk_gb    = 200
    os         = "CentOS 7"
    role       = "AppServer"
    apps       = ["java", "tomcat"]
  },
  {
    name       = "PROD-BATCH-01"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.30"
    cpu        = 4
    memory_gb  = 8
    disk_gb    = 500
    os         = "CentOS 7"
    role       = "BatchServer"
    apps       = ["python", "cron-jobs"]
  }
]

# -----------------------------------------------------------------------------
# Databases to Migrate (using AWS DMS)
# -----------------------------------------------------------------------------
vcenter_source_databases = {
  mysql = {
    name       = "PROD-MYSQL-01"
    type       = "MySQL 5.7"
    ip_address = "192.168.1.50"
    port       = 3306
    size_gb    = 500
    databases  = ["app_production", "app_analytics"]
  }
  postgres = {
    name       = "PROD-POSTGRES-01"
    type       = "PostgreSQL 12"
    ip_address = "192.168.1.51"
    port       = 5432
    size_gb    = 300
    databases  = ["reporting", "audit_logs"]
  }
}

# -----------------------------------------------------------------------------
# Migration Waves Planning
# -----------------------------------------------------------------------------
migration_waves = {
  wave1 = {
    name        = "Web Tier Migration"
    start_date  = "2024-02-01"
    servers     = ["PROD-WEB-01", "PROD-WEB-02"]
    cutover     = "2024-02-15"
  }
  wave2 = {
    name        = "App Tier Migration"
    start_date  = "2024-02-16"
    servers     = ["PROD-APP-01", "PROD-APP-02"]
    cutover     = "2024-03-01"
  }
  wave3 = {
    name        = "Database Migration"
    start_date  = "2024-03-02"
    servers     = ["PROD-MYSQL-01", "PROD-POSTGRES-01"]
    cutover     = "2024-03-15"
  }
  wave4 = {
    name        = "Batch & Supporting"
    start_date  = "2024-03-16"
    servers     = ["PROD-BATCH-01"]
    cutover     = "2024-03-30"
  }
}

# -----------------------------------------------------------------------------
# AWS Target Configuration
# -----------------------------------------------------------------------------
aws_target_mapping = {
  "PROD-WEB-01"   = { instance_type = "t3.large",   subnet = "private" }
  "PROD-WEB-02"   = { instance_type = "t3.large",   subnet = "private" }
  "PROD-APP-01"   = { instance_type = "m5.xlarge",  subnet = "private" }
  "PROD-APP-02"   = { instance_type = "m5.xlarge",  subnet = "private" }
  "PROD-BATCH-01" = { instance_type = "c5.xlarge",  subnet = "private" }
}
