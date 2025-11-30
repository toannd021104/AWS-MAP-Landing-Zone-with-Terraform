# =============================================================================
# IAM Module - Outputs
# =============================================================================

output "admin_role_arn" {
  description = "Admin IAM Role ARN"
  value       = aws_iam_role.admin.arn
}

output "admin_role_name" {
  description = "Admin IAM Role Name"
  value       = aws_iam_role.admin.name
}

output "developer_role_arn" {
  description = "Developer IAM Role ARN"
  value       = aws_iam_role.developer.arn
}

output "developer_role_name" {
  description = "Developer IAM Role Name"
  value       = aws_iam_role.developer.name
}

output "readonly_role_arn" {
  description = "ReadOnly IAM Role ARN"
  value       = aws_iam_role.readonly.arn
}

output "readonly_role_name" {
  description = "ReadOnly IAM Role Name"
  value       = aws_iam_role.readonly.name
}

output "cicd_role_arn" {
  description = "CI/CD IAM Role ARN"
  value       = aws_iam_role.cicd.arn
}

output "cicd_role_name" {
  description = "CI/CD IAM Role Name"
  value       = aws_iam_role.cicd.name
}

output "ec2_instance_role_arn" {
  description = "EC2 Instance Role ARN"
  value       = aws_iam_role.ec2_instance.arn
}

output "ec2_instance_profile_name" {
  description = "EC2 Instance Profile Name"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_profile_arn" {
  description = "EC2 Instance Profile ARN"
  value       = aws_iam_instance_profile.ec2.arn
}

output "lambda_execution_role_arn" {
  description = "Lambda Execution Role ARN"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_execution_role_name" {
  description = "Lambda Execution Role Name"
  value       = aws_iam_role.lambda_execution.name
}

output "ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "ECS Task Execution Role Name"
  value       = aws_iam_role.ecs_task_execution.name
}

output "admins_group_name" {
  description = "Admins IAM Group Name"
  value       = aws_iam_group.admins.name
}

output "developers_group_name" {
  description = "Developers IAM Group Name"
  value       = aws_iam_group.developers.name
}

output "readonly_users_group_name" {
  description = "ReadOnly Users IAM Group Name"
  value       = aws_iam_group.readonly_users.name
}
