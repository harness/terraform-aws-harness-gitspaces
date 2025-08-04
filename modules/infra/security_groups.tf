resource "aws_security_group" "gateway_sg" {
  name        = "${local.name}-gateway-sg"
  description = "Security group for gateway instances"
  vpc_id      = aws_vpc.vpc_network.id

  tags = {
    Name = "${local.name}-gateway-sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "gitspace_sg" {
  name        = "${local.name}-gitspace-sg"
  description = "Security group for gitspace instances"
  vpc_id      = aws_vpc.vpc_network.id

  tags = {
    Name = "${local.name}-gitspace-sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "${local.name}-lb-sg"
  description = "Security group for load balancers"
  vpc_id      = aws_vpc.vpc_network.id

  tags = {
    Name = "${local.name}-lb-sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_rule_22" {
  security_group_id = aws_security_group.lb_sg.id
  description       = "Allow traffic from internet to gateway ssh (debugging)"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_rule_80" {
  security_group_id = aws_security_group.lb_sg.id
  description       = "Allow traffic from internet to health endpoint"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_rule_443" {
  security_group_id = aws_security_group.lb_sg.id
  description       = "Allow traffic from internet to envoy https endpoint"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_rule_2117" {
  security_group_id = aws_security_group.lb_sg.id
  description       = "Allow traffic from internet to gateway https endpoint"
  from_port         = 2117
  to_port           = 2117
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_rule_2118" {
  security_group_id = aws_security_group.lb_sg.id
  description       = "Allow traffic from internet to gateway http endpoint"
  from_port         = 2118
  to_port           = 2118
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_rule_2200" {
  security_group_id = aws_security_group.lb_sg.id
  description       = "Allow traffic from internet to envoy ssh endpoint"
  from_port         = 2200
  to_port           = 2200
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "gateway_sg_ingress_rule_22" {
  security_group_id            = aws_security_group.gateway_sg.id
  description                  = "Allow traffic from lb to gateway ssh (debugging)"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "gateway_sg_ingress_rule_80" {
  security_group_id            = aws_security_group.gateway_sg.id
  description                  = "Allow traffic from lb to health endpoint"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "gateway_sg_ingress_rule_443" {
  security_group_id            = aws_security_group.gateway_sg.id
  description                  = "Allow traffic from lb to envoy https endpoint"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "gateway_sg_ingress_rule_2117" {
  security_group_id            = aws_security_group.gateway_sg.id
  description                  = "Allow traffic from lb to gateway https endpoint"
  from_port                    = 2117
  to_port                      = 2117
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "gateway_sg_ingress_rule_2118" {
  security_group_id            = aws_security_group.gateway_sg.id
  description                  = "Allow traffic from lb to gateway http endpoint"
  from_port                    = 2118
  to_port                      = 2118
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "gateway_sg_ingress_rule_2200" {
  security_group_id            = aws_security_group.gateway_sg.id
  description                  = "Allow traffic from lb to envoy ssh endpoint"
  from_port                    = 2200
  to_port                      = 2200
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "gateway_sg_ingress_rule_6379" {
  security_group_id            = aws_security_group.gateway_sg.id
  description                  = "Allow traffic between redis and gateway instances"
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.gateway_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "gitspace_sg_ingress_rule_2200_65000" {
  security_group_id            = aws_security_group.gitspace_sg.id
  description                  = "Allow traffic from gateway to gitspace vm"
  from_port                    = 2200
  to_port                      = 65000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.gateway_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "gitspace_sg_ingress_rule_9079" {
  security_group_id = aws_security_group.gitspace_sg.id
  description       = "Allow traffic from internet to lite-engine (debugging)"
  from_port         = 9079
  to_port           = 9079
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "gitspace_egress" {
  security_group_id = aws_security_group.gitspace_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "gateway_egress" {
  security_group_id = aws_security_group.gateway_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "lb_egress" {
  security_group_id = aws_security_group.lb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}