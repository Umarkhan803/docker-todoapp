provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
# Security Group - allows HTTP and SSH
resource "aws_security_group" "todo_sg" {
  name        = "todo-app-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins port
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate a private key
resource "tls_private_key" "todo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create key pair in AWS using the generated public key
resource "aws_key_pair" "todo_key" {
  key_name   = "todo-key"
  public_key = tls_private_key.todo_key.public_key_openssh
}
resource "local_file" "private_key" {
  content         = tls_private_key.todo_key.private_key_pem
  filename        = "${path.module}/todo-key.pem"
  file_permission = "0400" # Read-only, like chmod 400
}
# EC2 Instance
resource "aws_instance" "todo_app" {
  ami                    = var.ami_id # Amazon Linux 2 us-east-1
  instance_type          = var.instance_type
  key_name               = aws_key_pair.todo_key.key_name
  vpc_security_group_ids = [aws_security_group.todo_sg.id]
  user_data              = file("userdata.sh")

  tags = {
    Name = "todo-app-server"
  }
}
