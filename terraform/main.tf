provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "deploy-mate-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_ecs_cluster" "deploy_mate" {
  name = "deploy-mate-dev"
}

resource "aws_iam_role" "ecs_execution" {
  name = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

module "deploy_mate_alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "deploy_mate" {
  source                = "./modules/fargate"
  cluster_id            = aws_ecs_cluster.deploy_mate.id
  service_name          = "deploy-mate"
  execution_role_arn    = aws_iam_role.ecs_execution.arn
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  target_group_arn      = module.deploy_mate_alb.target_group_arn
  alb_security_group_id = module.deploy_mate_alb.alb_security_group_id
}

resource "aws_ecr_repository" "services" {
  name         = "deploy-mate-dev"
  force_delete = true
}
