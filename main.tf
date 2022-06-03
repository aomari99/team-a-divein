provider "aws" {
  region = local.region
}

locals {
  name   = "replica-mysql"
  region = "eu-west-1"
  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  engine                = "mysql"
  engine_version        = "8.0.27"
  family                = "mysql8.0" # DB parameter group
  major_engine_version  = "8.0"      # DB option group
  instance_class        = "db.t1.micro" 
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = 3306
}


################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  create_database_subnet_group = true

  tags = local.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Wordpress Database sg"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}



variable "ecs_task_definition_family" {
  description = "Specify a family for a task definition, which allows you to track multiple versions of the same task definition"
  type        = string
  default     = "wordpress-family"
}

variable "ecs_task_definition_cpu" {
  description = "Number of CPU units reserved for the container in powers of 2"
  type        = string
  default     = "1024"
}

variable "ecs_task_definition_memory" {
  description = "Specify a family for a task definition, which allows you to track multiple versions of the same task definition"
  type        = string
  default     = "2048"
}

variable "db_master_username" {
  description = "Master username of the db"
}
variable "db_master_password" {
  description = "Master password of the db"
}

variable "ecs_service_name" {
  description = "Name for the ECS Service"
  type        = string
  default     = "wordpress"
}

variable "ecs_service_desired_count" {
  description = "The number of instances of fargate tasks to keep running"
  type        = number
  default     = 1
}

################################################################################
# Master DB
################################################################################

module "master" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}-master"

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  db_name  = "replicaMysql"
  username = "replica_mysql"
  port     = local.port

  multi_az               = True
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  # Backups are required in order to create a replica
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = local.tags
}

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
        "valueFROM": "test"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD", 
        "valueFROM": "test"
      }
    ],
    "environment": [
      {
        "name": "WORDPRESS_DB_HOST",
        "value": "${module.master.this.endpoint}"
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

 data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}
 


 



data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}



resource "aws_iam_role" "ecs_task_role" {
  name               = "wordpressTaskRole"
  description = "IAM Role for task to use to access AWS services (dynamo, s3, etc.)"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "wordpressTaskPolicy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_role_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

################################################################################
# Replica DB
################################################################################
/*
module "replica" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}-replica"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db    = module.master.db_instance_id
  create_random_password = false

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  port = local.port

  multi_az               = false
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Tue:00:00-Tue:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = local.tags
}*/