resource "aws_alb" "alb" {
  name                             = var.name
  subnets                          = flatten(var.subnet_ids)
  enable_cross_zone_load_balancing = length(var.subnet_ids) > 1 ? true : false
  security_groups                  = var.sg_ids
  idle_timeout                     = 10
  tags                             = var.tags
}

resource "aws_alb_target_group" "target_group" {
  count       = length(var.target_groups)
  name        = lookup(var.target_groups[count.index], "name")
  port        = lookup(var.target_groups[count.index], "port")
  protocol    = lookup(var.target_groups[count.index], "protocol")
  target_type = lookup(var.target_groups[count.index], "target_type")
  vpc_id      = var.vpc_id
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_lb_listener.listener
  ]
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

resource "aws_lb_listener" "listener" {
  count             = var.listeners_count
  load_balancer_arn = aws_alb.alb.arn
  certificate_arn   = var.listeners[count.index]["ssl_cert_arn"]
  port              = var.listeners[count.index]["port"]
  protocol          = var.listeners[count.index]["protocol"]

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found."
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "listener_rule" {
  count        = length(aws_lb_listener.listener[*].arn)
  listener_arn = aws_lb_listener.listener[count.index].arn
  priority     = 10

  dynamic "action" {
    for_each = aws_alb_target_group.target_group[*].arn
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
