output "target_group_arn" {
  value = join("", aws_alb_target_group.target_group[*].arn)
}

output "lb_dns_name" {
  value = join("", aws_alb.alb[*].dns_name)
}
output "lb_dns_zone_id" {
  value = join("", aws_alb.alb[*].zone_id)
}
