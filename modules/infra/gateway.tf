locals {
  gateway_suffix = "${replace(local.gateway_version, ".", "-")}-${substr(uuid(), 0, 8)}"
}

resource "aws_launch_template" "default_template" {
  for_each = local.gateway_deploy ? {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  } : {}


  name          = "${local.name}-${local.region_configs[each.key].region_name}-gateway-template-${local.gateway_suffix}"
  image_id      = local.region_configs[each.key].gateway_ami_id
  instance_type = local.gateway_machine_type

  #   key_name = can(each.value.key_name) && each.value.key_name != "" ? each.value.key_name : null

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  network_interfaces {
    security_groups             = [aws_security_group.gateway_sg.id]
    associate_public_ip_address = false
  }

  user_data = base64encode(templatefile("${path.module}/scripts/gateway-init.sh", {
    gateway_secret     = local.gateway_secret
    cde_manager_url    = local.cde_manager_url
    region_name        = local.region_configs[each.key].region_name
    gateway_suffix     = local.gateway_suffix
    gateway_version    = local.gateway_version
    name               = local.name
    account_identifier = local.account_identifier
    infra_provider     = local.infra_provider_config_identifier
    gateway_url        = local.region_configs[each.key].domain
    group_name         = "${local.name}-${local.region_configs[each.key].region_name}-gateway-group-${local.gateway_suffix}"
  }))

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "optional"
    instance_metadata_tags = "enabled"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "gateway" {
  for_each = local.gateway_deploy ? {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  } : {}
  name = "${local.name}-${local.region_configs[each.key].region_name}-gateway-group-${local.gateway_suffix}"
  launch_template {
    id      = aws_launch_template.default_template[each.key].id
    version = "$Latest"
  }
  max_size = local.gateway_instances
  min_size = local.gateway_instances

  health_check_grace_period = 60
  health_check_type         = "EC2"

  target_group_arns = [
    aws_lb_target_group.nlb_default[each.key].arn,
    aws_lb_target_group.alb_default[each.key].arn,
    aws_lb_target_group.gateway_nlb_default[each.key].arn,
    aws_lb_target_group.gateway_nlb_default_mtls[each.key].arn,
    aws_lb_target_group.gateway_ssh[each.key].arn
  ]


  vpc_zone_identifier = [
    for subnet_key, subnet in local.all_private_subnets :
    aws_subnet.private_subnet[subnet_key].id
    if subnet.region_name == each.key
  ]

  depends_on = [
    aws_launch_template.default_template,
    aws_route_table_association.private_rta,
    aws_route_table_association.public_rta
  ]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_instance_profile" "provisioner_instance_profile" {
  name = "${local.name}-provisioner-instance-profile"
}