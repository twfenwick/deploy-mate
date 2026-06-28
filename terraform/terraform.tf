terraform {
  required_version = ">=1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.28.0"
    }
  }

  backend "s3" {
    bucket         = "global-terraform-state-bucket-twf"
    key            = "apps/deploy-mate/dev/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}
