# =============================================================================
# Security Module - Outputs
# =============================================================================

output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "guardduty_detector_arn" {
  description = "GuardDuty Detector ARN"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].arn : null
}

output "security_hub_arn" {
  description = "Security Hub ARN"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].arn : null
}

output "config_recorder_id" {
  description = "Config Recorder ID"
  value       = var.enable_config ? aws_config_configuration_recorder.main[0].id : null
}

output "kms_key_id" {
  description = "Security KMS Key ID"
  value       = aws_kms_key.security.key_id
}

output "kms_key_arn" {
  description = "Security KMS Key ARN"
  value       = aws_kms_key.security.arn
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Application Security Group ID"
  value       = aws_security_group.app.id
}

output "database_security_group_id" {
  description = "Database Security Group ID"
  value       = aws_security_group.database.id
}

output "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  value       = aws_security_group.bastion.id
}
