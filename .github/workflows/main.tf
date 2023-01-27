terraform {
  backend "s3" {
    bucket = "terraform-backend-561678142736"
    region = "ap-northeast-1"
    key    = "terraform-aws-ec2-saver.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }
  required_version = "~> 1.3.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

module "ec2_saver" {
  source = "../../"
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "main" {
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = "t3.nano"
  subnet_id     = "subnet-0abaada26acb8894f"
  key_name      = "kota65535"
  tags = {
    AutoStartTime = 10
    AutoStopTime  = 11
  }
  lifecycle {
    ignore_changes = [ami]
  }
}
