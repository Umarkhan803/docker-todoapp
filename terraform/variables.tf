variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro" # Free tier eligible
}

variable "todo-key" {
  description = "Your AWS EC2 Key Pair name"
}

variable "ami_id" {
  default = "ami-0f3caa1cf4417e51b"

}
