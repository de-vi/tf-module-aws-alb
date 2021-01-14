#tfsec:ignore:AWS005
resource "aws_alb" "alb" {
  name                             = var.name
  subnets                          = flatten(var.subnet_ids)
  enable_cross_zone_load_balancing = length(var.subnet_ids) > 1 ? true : false
  security_groups                  = var.sg_ids
  idle_timeout                     = 10
  tags                             = var.tags
  access_logs {
    bucket  = var.access_log_bucket
    prefix  = "${var.name}-alb"
    enabled = true
  }
}

resource "aws_alb_target_group" "target_group" {
  count    = length(var.target_groups)
  name     = var.target_groups[count.index]["name"]
  port     = var.target_groups[count.index]["port"]
  protocol = var.target_groups[count.index]["protocol"]
  vpc_id   = var.vpc_id
  tags     = var.tags

  lifecycle {
    create_before_destroy = true
  }

  dynamic "health_check" {
    for_each = var.target_group_health_checks
    iterator = target_group_health_checks
    content {
      healthy_threshold   = lookup(target_group_health_checks.value, "healthy_threshold")
      unhealthy_threshold = lookup(target_group_health_checks.value, "unhealthy_threshold")
      interval            = lookup(target_group_health_checks.value, "interval")
      path                = lookup(target_group_health_checks.value, "path")
      matcher             = lookup(target_group_health_checks.value, "matcher")
      protocol            = lookup(target_group_health_checks.value, "protocol")
      timeout             = lookup(target_group_health_checks.value, "timeout")
    }
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  #checkov:skip=CKV_AWS_2:Ignore HTTPS protocol check
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  #checkov:skip=CKV_AWS_2:Ignore HTTPS protocol check
  protocol        = "HTTPS"
  certificate_arn = var.ssl_cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group[0].arn
  }
}

locals {
  additional_target_groups = slice(aws_alb_target_group.target_group[*].arn, 1, length(aws_alb_target_group.target_group[*].arn))
}

resource "aws_lb_listener_rule" "listener_rule" {
  count        = length(local.additional_target_groups) > 0 ? 1 : 0
  listener_arn = aws_lb_listener.https_listener.arn

  dynamic "action" {
    for_each = local.additional_target_groups
    iterator = arn
    content {
      type             = "forward"
      target_group_arn = arn.value
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
