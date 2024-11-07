terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "terraform-state-bucket-oshri"
    key = "weather_app_ec2/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
    region = "eu-north-1"  
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-north-1"  
}


resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Security group for EC2 instance with SSH, HTTP, and HTTPS access"


  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "ec2_terraform" {
  ami           = "ami-08eb150f611ca277f"
  instance_type = "t3.micro"
  key_name = var.ssh_key


  security_groups = [aws_security_group.ec2_sg.name]
  

  tags = {
    Name = "ec2_terraform"
  }
}


resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-state-bucket-oshri"  
  acl    = "private"

  versioning {
    enabled = true  
  }
}

resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "terraform-state-lock"  
  billing_mode = "PAY_PER_REQUEST"       

  hash_key = "LockID"                   

  attribute {
    name = "LockID"
    type = "S"
  }
}
