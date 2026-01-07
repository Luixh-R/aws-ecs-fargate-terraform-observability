output "project_name" {
  value = var.project_name
}

output "environment" {
  value = var.environment
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "ecs_log_group" {
  value = aws_cloudwatch_log_group.ecs.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "alb_url" {
  description = "Public URL of the application load balancer"
  value       = aws_lb.app.dns_name
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${aws_lb.app.dns_name}:9090"
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${aws_lb.app.dns_name}:3000"
}

data "aws_caller_identity" "current" {}
