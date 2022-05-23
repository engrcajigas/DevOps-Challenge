output "security_group_alb" {
  value = aws_security_group.security_group_alb
}

output "alb" {
  value = aws_lb.alb
}

output "alb_target_group" {
  value = aws_lb_target_group.target_group
}
