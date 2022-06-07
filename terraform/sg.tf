#database Security group allowing only traffic through port MYSQL DB Port 3306
module "security_group_db" {
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
    } 
]/*
  egress_with_cidr_blocks = [{
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = "0.0.0.0/0"
      }
  ]*/
  
  tags = local.tags
}

module "security_group_wordpress" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "wordpress"
  description = "Wordpress sg"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Wordpress get accessed from anywhere"
      cidr_blocks = "0.0.0.0/0"
    } 
] 
  egress_with_cidr_blocks = [{
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    description = "Wordpress access data from anywhere"
    cidr_blocks = "0.0.0.0/0"
      }
  ] 
  
  tags = local.tags
}