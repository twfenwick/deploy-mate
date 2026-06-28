provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "deploy-mate-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"] #, "us-east-1b"]
  private_subnets = ["10.0.1.0/24"] #, "10.0.2.0/24"]
  # public_subnets  = ["10.0.101.0/24"] #, "10.0.102.0/24"]

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_ecr_repository" "services" {
  name = "deploy-mate"
  force_delete = true
}

resource "aws_iam_policy" "policy" {
  name        = "ecr-policy"
  path        = "/"
  description = "deploy-mate-ecr"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",
          "ecr:ListTagsForResource",
          "ecr:TagResource",
          "ecr:UntagResource",
          "ecr:PutImageTagMutability",
          "ecr:PutLifecyclePolicy",
          "ecr:GetLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy"
        ],
        "Resource": "arn:aws:ecr:us-east-1:YOUR_ACCOUNT_ID:repository/*"
      },
      {
        "Effect": "Allow",
        "Action": "ecr:GetAuthorizationToken",
        "Resource": "*"
      }
    ]
  })
}
