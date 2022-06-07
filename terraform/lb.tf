resource "aws_lb" "wordpress" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = "application"
  security_groups    = [module.security_group_wordpress.security_group_id]
  subnets            = module.vpc.public_subnets
  tags               = local.tags
}

resource "aws_lb_listener" "wordpress_http" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_http.arn
  }
}


resource "aws_lb_target_group" "wordpress_http" {
  name        = var.lb_target_group_http
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    matcher = "200-499"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
  tags = local.tags
}