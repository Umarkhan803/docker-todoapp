provider "aws" {
  region = var.aws_region
}

# --- ECR Repositories (stores your Docker images) ---
resource "aws_ecr_repository" "backend" {
  name = "todo-backend"
}

resource "aws_ecr_repository" "frontend" {
  name = "todo-frontend"
}

# --- ECS Cluster (runs your containers) ---
resource "aws_ecs_cluster" "todo_cluster" {
  name = "todo-cluster"
}

# --- IAM Role for ECS Task ---
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- ECS Task Definition (defines what containers to run) ---
resource "aws_ecs_task_definition" "todo_task" {
  family                   = "todo-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = "${aws_ecr_repository.backend.repository_url}:${var.image_tag}"
      essential    = true
      portMappings = [{ containerPort = 5000 }]
    },
    {
      name         = "frontend"
      image        = "${aws_ecr_repository.frontend.repository_url}:${var.image_tag}"
      essential    = true
      portMappings = [{ containerPort = 80 }]
    }
  ])
}

# --- Security Group ---
resource "aws_security_group" "todo_sg" {
  name   = "todo-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ECS Service (keeps containers running) ---
resource "aws_ecs_service" "todo_service" {
  name            = "todo-service"
  cluster         = aws_ecs_cluster.todo_cluster.id
  task_definition = aws_ecs_task_definition.todo_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.todo_sg.id]
    assign_public_ip = true
  }
}
