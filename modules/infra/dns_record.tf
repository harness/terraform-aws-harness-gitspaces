resource "aws_route53_record" "nlb" {
  for_each = var.manage_dns_zone ? {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  } : {}

  zone_id = data.aws_route53_zone.existing.zone_id
  name    = local.region_configs[each.key].domain
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.nlb[each.key].dns_name]
}

resource "aws_route53_record" "wildcard" {
  for_each = var.manage_dns_zone ? {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  } : {}

  zone_id = data.aws_route53_zone.existing.zone_id
  name    = "*.${local.region_configs[each.key].domain}"
  type    = "CNAME"
  ttl     = 300
  records = [local.region_configs[each.key].domain]
}

data "aws_route53_zone" "existing" {
  name         = local.domain
  private_zone = false
}