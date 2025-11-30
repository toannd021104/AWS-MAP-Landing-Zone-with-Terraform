# =============================================================================
# Compute Module - Outputs
# =============================================================================

output "web_instance_ids" {
  description = "IDs of web server instances"
  value       = aws_instance.web[*].id
}

output "web_private_ips" {
  description = "Private IPs of web server instances"
  value       = aws_instance.web[*].private_ip
}

output "app_instance_ids" {
  description = "IDs of application server instances"
  value       = aws_instance.app[*].id
}

output "app_private_ips" {
  description = "Private IPs of application server instances"
  value       = aws_instance.app[*].private_ip
}

output "web_security_group_id" {
  description = "Security group ID for web servers"
  value       = aws_security_group.web.id
}

output "app_security_group_id" {
  description = "Security group ID for app servers"
  value       = aws_security_group.app.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.create_alb ? aws_lb.web[0].dns_name : null
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.create_alb ? aws_lb.web[0].arn : null
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = var.create_alb ? aws_lb.web[0].zone_id : null
}

# Migration tracking outputs
output "migration_summary" {
  description = "Summary of migrated workloads"
  value = {
    total_web_servers = var.web_server_count
    total_app_servers = var.app_server_count
    source_datacenter = distinct([for vm in var.vcenter_source_vms : vm.datacenter])
    migration_program = "AWS-MAP"
  }
}
