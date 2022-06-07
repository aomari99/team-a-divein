################################################################################
# Master DB
################################################################################

module "master_db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}-master"

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  db_name  = "wordpress"
  username = var.db_master_username
  #publicly_accessible    = true
  password = var.db_master_password
  port     = local.port

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [module.security_group_db.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  # Backups are required in order to create a replica
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = local.tags
}
