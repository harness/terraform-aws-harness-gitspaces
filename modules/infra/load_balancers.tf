locals {
  vpc_id = aws_vpc.vpc_network.id
}

resource "aws_lb_target_group" "nlb_default" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  name        = "${local.name}-nlb"
  port        = 2200
  protocol    = "TCP"
  vpc_id      = local.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_target_group" "gateway_ssh" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  name        = "${local.name}-gw-ssh"
  port        = 22
  protocol    = "TCP"
  vpc_id      = local.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_target_group" "gateway_nlb_default" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  name        = "${local.name}-gw-nlb"
  port        = 2118
  protocol    = "TCP"
  vpc_id      = local.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_target_group" "gateway_nlb_default_mtls" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  name        = "${local.name}-gw-nlb-mtls"
  port        = 2117
  protocol    = "TCP"
  vpc_id      = local.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = 80
  }
}

resource "aws_lb_target_group" "alb_default" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  name        = "${local.name}-alb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    path     = "/health"
    port     = 80
  }
}

resource "aws_lb_target_group" "alb_ingress" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  name        = "${local.name}-alb-ingress"
  port        = 443
  protocol    = "TCP"
  vpc_id      = local.vpc_id
  target_type = "alb"

  target_health_state {
    enable_unhealthy_connection_termination = false
  }

  health_check {
    protocol = "HTTP"
    path     = "/health"
    port     = 80
  }
}

resource "aws_lb" "nlb" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  name               = "${local.name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets = [
    for k, v in local.all_public_subnets :
    aws_subnet.public_subnet[k].id if v.region_name == each.key
  ]
  security_groups = [aws_security_group.lb_sg.id]
  ip_address_type = "ipv4"
}

resource "aws_lb" "alb" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    for key, subnet in aws_subnet.public_subnet :
    subnet.id if startswith(key, each.key)
  ]
  security_groups = [aws_security_group.lb_sg.id]
  ip_address_type = "ipv4"
}

resource "aws_lb_listener" "gateway_nlb_listener_ssh" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  load_balancer_arn = aws_lb.nlb[each.key].arn
  port              = 22
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_ssh[each.key].arn
  }
}

resource "aws_lb_listener" "nlb_listener" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  load_balancer_arn = aws_lb.nlb[each.key].arn
  port              = 2200 # Needs to be a range from 2200 to 65000
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_default[each.key].arn
  }
}

resource "aws_lb_listener" "gateway_nlb_listener_mtls" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  load_balancer_arn = aws_lb.nlb[each.key].arn
  port              = 2117
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_nlb_default_mtls[each.key].arn
  }
}

resource "aws_lb_listener" "gateway_nlb_listener" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  load_balancer_arn = aws_lb.nlb[each.key].arn
  port              = 2118
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_nlb_default[each.key].arn
  }
}

resource "aws_lb_listener" "alb_listener" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  load_balancer_arn = aws_lb.nlb[each.key].arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ingress[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "alb_ingress_target" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  target_group_arn = aws_lb_target_group.alb_ingress[each.key].arn
  target_id        = aws_lb.alb[each.key].arn
  port             = 443
  depends_on       = [aws_lb_listener.https_listener]
}

resource "aws_lb_listener" "http_listener" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  load_balancer_arn = aws_lb.alb[each.key].arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_default[each.key].arn
  }
}

resource "aws_lb_listener" "https_listener" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  load_balancer_arn = aws_lb.alb[each.key].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.use_certificate_manager ? data.aws_acm_certificate.cert[each.key].arn : aws_acm_certificate.default[each.key].arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_default[each.key].arn
  }
}

resource "aws_lb_listener_rule" "url_routing" {
  for_each = {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  }
  listener_arn = aws_lb_listener.https_listener[each.key].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_default[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

data "aws_acm_certificate" "cert" {
  for_each = var.use_certificate_manager ? {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  } : {}
  domain      = "*.${each.value.domain}"
  statuses    = ["ISSUED"]
  most_recent = true
}


resource "aws_acm_certificate" "default" {
  for_each = var.use_certificate_manager == false ? {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  } : {}
  private_key       = file(var.private_key_path)
  certificate_body  = file(var.certificate_path)
  certificate_chain = file(var.chain_path)
}
