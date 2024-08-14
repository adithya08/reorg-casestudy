resource "aws_ecr_repository" "fastapi_repo" {
  name = "fastapi_repo"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
    name = "fastapi-cluster"
}

resource "aws_ecs_task_definition" "td" {
    family                   = "fastapi"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "512"
    memory                   = "1024"
    container_definitions = jsonencode([
        {
        name      = "fastapi-container"
        image     = "${aws_ecr_repository.fastapi_repo.repository_url}:latest"
        essential = true
        portMappings = [
            {
            containerPort = 80
            hostPort      = 80
            }
        ]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                awslogs-group = "${aws_ecs_cluster.ecs_cluster.name}"
                awslogs-region = "${var.region}"
                awslogs-stream-prefix = "ecs"
            }
        }
        }
    ])
}

resource "aws_ecs_service" "ecs_service" {
    name            = "fastapi-service"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.td.arn
    desired_count   = "1"
    launch_type     = "FARGATE"

    network_configuration {
        security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = aws_subnet.pri_subnet.id
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_alb_target_group.ecs_tg.id
        container_name   = "fastapi-container"
        container_port   = "80"
    }
    depends_on = [aws_alb_listener.ecs_listener]
}