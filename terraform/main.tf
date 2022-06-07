# terraform {
#   backend "s3" {
#     bucket = "wordpress-teama"
#     region = "eu-west-1"
#   }
# }
provider "aws" {
  region = local.region
 
}

locals {
  name   = "wordpress-db"
  region = "eu-west-1"
  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  engine                = "mysql"
  engine_version        = "8.0.27"
  family                = "mysql8.0" # DB parameter group
  major_engine_version  = "8.0"      # DB option group
  instance_class        = "db.t4g.micro" 
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = 3306
}