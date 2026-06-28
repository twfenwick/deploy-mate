data "aws_caller_identity" "current" {}

resource "aws_security_group" "service" {
  name   = "${var.service_name}-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "service" {
  security_group_id = aws_security_group.service.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256 # Consider making a variable and increase for startup time
  memory                   = 512 # Consider making a variable and increase for startup time
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([{
    name = var.service_name
    # 3. Update image references in modules/fargate/main.tf
    image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/deploy-mate:latest"
    portMappings = [{
        containerPort = 8087
        hostPort      = 8087
        protocol      = "tcp"
      }]
  }])
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = false
  }
  # service_registries {
  #   registry_arn = aws_service_discovery_service.this.arn
  # }
}

