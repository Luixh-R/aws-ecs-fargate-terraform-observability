variable "project_name" {
  description = "Project name used for tagging and naming"
  type        = string
  default     = "ecs-fargate-observability"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

