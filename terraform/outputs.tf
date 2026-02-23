output "ec2_public_ip" {
  value       = aws_instance.todo_app.public_ip
  description = "Public IP of your EC2 instance"
}
