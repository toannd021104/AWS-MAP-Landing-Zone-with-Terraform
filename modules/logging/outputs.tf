# =============================================================================
# Logging Module - Outputs
# =============================================================================

output "log_bucket_name" {
  description = "Name of the S3 bucket for logs"
  value       = aws_s3_bucket.logs.id
}

output "log_bucket_arn" {
  description = "ARN of the S3 bucket for logs"
  value       = aws_s3_bucket.logs.arn
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].id : null
}

output "cloudtrail_log_group_arn" {
  description = "CloudTrail CloudWatch Log Group ARN"
  value       = var.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail[0].arn : null
}

output "application_log_group_arn" {
  description = "Application CloudWatch Log Group ARN"
  value       = aws_cloudwatch_log_group.application.arn
}

output "application_log_group_name" {
  description = "Application CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.application.name
}

output "alerts_sns_topic_arn" {
  description = "SNS Topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "kms_key_arn" {
  description = "Logging KMS Key ARN"
  value       = aws_kms_key.logging.arn
}

output "kms_key_id" {
  description = "Logging KMS Key ID"
  value       = aws_kms_key.logging.key_id
}
