terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Local state is fine for a solo portfolio project (it's gitignored).
  # TODO (stretch): move to S3 backend with locking and explain why in the README.
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = "aws-secure-delivery-pipeline"
      ManagedBy = "terraform"
    }
  }
}

# IAM is a global service: its CloudTrail events land in us-east-1,
# so the detection rule must live there regardless of var.region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      Project   = "aws-secure-delivery-pipeline"
      ManagedBy = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
