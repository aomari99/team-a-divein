output "Load_Balancer_Address" {
  value = aws_lb.wordpress.dns_name
}