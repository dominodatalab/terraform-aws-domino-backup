data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "dst_account" {
  provider = aws.dst
}

data "aws_region" "dst_region" {
  provider = aws.dst
}

terraform {
  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.dst]
    }
  }
}