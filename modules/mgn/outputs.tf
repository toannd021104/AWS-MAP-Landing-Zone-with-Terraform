# =============================================================================
# AWS MGN Module - Outputs
# =============================================================================

output "mgn_agent_role_arn" {
  description = "ARN of the MGN agent IAM role"
  value       = var.enable_mgn ? aws_iam_role.mgn_agent[0].arn : null
}

output "mgn_replication_role_arn" {
  description = "ARN of the MGN replication IAM role"
  value       = var.enable_mgn ? aws_iam_role.mgn_replication[0].arn : null
}

output "mgn_replication_instance_profile_arn" {
  description = "ARN of the MGN replication instance profile"
  value       = var.enable_mgn ? aws_iam_instance_profile.mgn_replication[0].arn : null
}

output "mgn_conversion_role_arn" {
  description = "ARN of the MGN conversion IAM role"
  value       = var.enable_mgn ? aws_iam_role.mgn_conversion[0].arn : null
}

output "mgn_conversion_instance_profile_arn" {
  description = "ARN of the MGN conversion instance profile"
  value       = var.enable_mgn ? aws_iam_instance_profile.mgn_conversion[0].arn : null
}

output "replication_security_group_id" {
  description = "ID of the MGN replication security group"
  value       = var.enable_mgn && var.create_security_groups ? aws_security_group.mgn_replication[0].id : null
}

output "target_security_group_id" {
  description = "ID of the MGN target security group"
  value       = var.enable_mgn && var.create_security_groups ? aws_security_group.mgn_target[0].id : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for MGN"
  value       = var.enable_mgn ? aws_cloudwatch_log_group.mgn[0].name : null
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for MGN notifications"
  value       = var.enable_mgn && var.enable_notifications ? aws_sns_topic.mgn_notifications[0].arn : null
}

# -----------------------------------------------------------------------------
# MGN Agent Installation Instructions
# -----------------------------------------------------------------------------
data "aws_region" "current" {}

locals {
  mgn_instructions = <<-EOT
================================================================================
AWS MGN Agent Installation Instructions
================================================================================

1. Download the AWS MGN Agent on each source server:

   For Linux:
   $ wget -O ./aws-replication-installer-init https://aws-application-migration-service-${data.aws_region.current.name}.s3.${data.aws_region.current.name}.amazonaws.com/latest/linux/aws-replication-installer-init
   $ chmod +x aws-replication-installer-init
   $ sudo ./aws-replication-installer-init --region ${data.aws_region.current.name} --aws-access-key-id YOUR_ACCESS_KEY --aws-secret-access-key YOUR_SECRET_KEY

   For Windows:
   Download from: https://aws-application-migration-service-${data.aws_region.current.name}.s3.${data.aws_region.current.name}.amazonaws.com/latest/windows/AwsReplicationWindowsInstaller.exe
   Run: AwsReplicationWindowsInstaller.exe --region ${data.aws_region.current.name} --aws-access-key-id YOUR_ACCESS_KEY --aws-secret-access-key YOUR_SECRET_KEY

2. Monitor replication status in AWS Console:
   https://console.aws.amazon.com/mgn/home?region=${data.aws_region.current.name}#/sourceServers

3. Launch test instances to validate migration

4. Perform cutover when ready

================================================================================
EOT
}

output "agent_installation_instructions" {
  description = "Instructions for installing MGN agent on source servers"
  value       = var.enable_mgn ? local.mgn_instructions : null
}
