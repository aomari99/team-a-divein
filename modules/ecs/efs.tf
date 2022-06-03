resource "aws_efs_access_point" "wordpress" {
  file_system_id = aws_efs_file_system.wordpress.id
}

resource "aws_efs_file_system" "wordpress" {
  creation_token = "wordpress"
  encrypted      = true
  tags           = var.tags
}

resource "aws_efs_mount_target" "wordpress" {
  count          = length(module.vpc.private_subnets)
  file_system_id = aws_efs_file_system.wordpress.id
  subnet_id      = module.vpc.private_subnets[count.index]
  security_groups = [
    aws_security_group.efs.id
  ]
}

resource "aws_security_group" "efs" {
  name        = "wordpress-efs"
  description = "Allow traffic from self"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    self      = true
  }
  tags = var.tags
}