resource "aws_ecs_cluster" "wordpress" {
  name = var.ecs_cluster_name
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
  container_definitions    = templatefile(
    "./wordpress.tpl",
    {
      wordpress_db_host          = module.master_db.db_instance_endpoint
      wordpress_db_user          = module.master_db.db_instance_username
      wordpress_db_password      = module.master_db.db_instance_password
      aws_region                 = local.region
      cloudwatch_log_group       = aws_cloudwatch_log_group.wordpress.name
    }
  )
}

resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/ecs/wordpress"
  tags              = local.tags
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
    security_groups = [module.security_group_wordpress.security_group_id]
    subnets         = module.vpc.public_subnets
    assign_public_ip = true
  }

}