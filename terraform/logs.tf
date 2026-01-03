resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"

  lifecycle {
   prevent_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-logs"
    Environment = var.environment
  }
}

