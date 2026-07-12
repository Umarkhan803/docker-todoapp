variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "image_tag" {
  description = "Docker image tag passed from Jenkins"
  type        = string
}
variable "IAM_role_name" {
  default     = "ecsTaskExecutionRole"
  description = "IAM role name for ECS task execution"
  type        = string
}

variable "vpc_id" {
  description = "Your AWS VPC ID — find it in AWS Console > VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in your VPC"
  type        = list(string)
}
