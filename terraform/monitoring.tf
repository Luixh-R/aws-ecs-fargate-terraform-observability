resource "aws_cloudwatch_log_group" "prometheus" {
  name = "/ecs/prometheus"
}

resource "aws_cloudwatch_log_group" "grafana" {
  name = "/ecs/grafana"
}

resource "aws_lb_target_group" "prometheus" {
  name        = "prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    path                = "/-/healthy"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "grafana" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "prometheus" {
  load_balancer_arn = aws_lb.app.arn
  port              = 9090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.app.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.project_name}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "prometheus"
      image = "prom/prometheus:latest"
      entryPoint = ["sh", "-c"]
      command = [
        <<-EOF
        cat > /tmp/prometheus.yml <<'CONFIG'
        global:
          scrape_interval: 15s
        scrape_configs:
          - job_name: "ecs-app"
            metrics_path: "/metrics"
            static_configs:
              - targets: ["${aws_lb.app.dns_name}:80"]
        CONFIG
        /bin/prometheus --config.file=/tmp/prometheus.yml
        EOF
      ]
      portMappings = [{ containerPort = 9090 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.prometheus.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "prometheus"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "prometheus" {
  name            = "${var.project_name}-prometheus-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  depends_on = [aws_lb_listener.prometheus]
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.project_name}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = "grafana/grafana:latest"
      entryPoint = ["sh", "-c"]
      command = [
        <<-EOF
        mkdir -p /etc/grafana/provisioning/datasources
        mkdir -p /etc/grafana/provisioning/dashboards

        cat > /etc/grafana/provisioning/datasources/prometheus.yaml <<'DATASOURCE'
        apiVersion: 1
        datasources:
          - name: Prometheus
            type: prometheus
            access: proxy
            url: http://${aws_lb.app.dns_name}:9090
            isDefault: true
        DATASOURCE

        cat > /etc/grafana/provisioning/dashboards/dashboards.yaml <<'DASHBOARDPROVIDER'
        apiVersion: 1
        providers:
          - name: 'FastAPI App Dashboard'
            orgId: 1
            folder: ''
            type: file
            disableDeletion: false
            updateIntervalSeconds: 10
            options:
              path: /etc/grafana/provisioning/dashboards
        DASHBOARDPROVIDER

        cat > /etc/grafana/provisioning/dashboards/fastapi-dashboard.json <<'DASHBOARD'
        {
          "id": null,
          "title": "FastAPI Request Count",
          "panels": [
            {
              "type": "table",
              "title": "Total Requests",
              "gridPos": {
                "h": 20,
                "w": 24,
                "x": 0,
                "y": 0
              },
              "targets": [
                { "expr": "app_requests_total", "refId": "A" }
              ]
            }
          ],
          "schemaVersion": 30,
          "version": 1
        }
        DASHBOARD

        /run.sh
        EOF
      ]
      portMappings = [{ containerPort = 3000, protocol = "tcp" }]
      environment = [
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = "admin" },
        { name = "GF_PATHS_PROVISIONING", value = "/etc/grafana/provisioning" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.project_name}-grafana-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.grafana.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.grafana]
}

