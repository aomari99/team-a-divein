resource "aws_ecs_cluster" "wordpress" {
  name = var.ecs_cluster_name
}

resource "aws_security_group" "wordpress" {
  name        = "$wordpress-sg"
  description = "Fargate wordpress security group"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_ssm_parameter" "db_master_user" {
  name  = "db_master_user"
  type  = "SecureString"
  value = var.db_master_username
  tags  = var.tags
}

resource "aws_ssm_parameter" "db_master_password" {
  name  = "db_master_password"
  type  = "SecureString"
  value = var.db_master_password
  tags  = var.tags
}

//Defining all parameters related to wordpress container
resource "aws_ecs_task_definition" "wordpress" {
  family                   = var.ecs_task_definition_family
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_definition_cpu
  memory                   = var.ecs_task_definition_memory
  container_definitions    = <<CONTAINER_DEFINITION
[
  {
    "secrets": [
      {
        "name": "WORDPRESS_DB_USER", 
        "valueFROM": "${aws_ssm_parameter.db_master_user.arn}"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD", 
        "valueFROM": "${aws_ssm_parameter.db_master_password.arn}"
      }
    ],
    "environment": [
      {
        "name": "WORDPRESS_DB_HOST",
        "value": "${aws_rds_cluster.this.endpoint}"
      },
      {
        "name": "WORDPRESS_DB_NAME",
        "value": "wordpress"
      }
    ],
    "essential": true,
    "image": "wordpress:latest",        
    "name": "wordpress",
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver":"awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.wordpress.name}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "app"
      }
    }
  }
]

CONTAINER_DEFINITION

}

resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/${var.prefix}/${var.environment}/fg-task"
  tags              = var.tags
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/ecs/wordpress"
  description       = " Log Group where ECS logs should be written"
  tags              = var.tags
  retention_in_days = var.log_retention_in_days
}


resource "aws_ecs_service" "wordpress" {
  name             = var.ecs_service_name
  cluster          = aws_ecs_cluster.wordpress.id
  task_definition  = aws_ecs_task_definition.wordpress.arn
  desired_count    = var.ecs_service_desired_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0" 
  network_configuration {
    security_groups = [aws_security_group.db.id]
    subnets         = module.vpc.public_subnets
  }

}