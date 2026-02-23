variable "aws_region" {
  default = "us-east-1"
}

variable "image_tag" {
  description = "Docker image tag passed from Jenkins"
}

variable "vpc_id" {
  description = "Your AWS VPC ID — find it in AWS Console > VPC"
}

variable "subnet_ids" {
  description = "List of subnet IDs in your VPC"
  type        = list(string)
}
