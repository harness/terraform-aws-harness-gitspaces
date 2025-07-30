resource "aws_acm_certificate" "default" {
  for_each = var.use_certificate_manager ? {
    for k, v in local.region_configs : k => v
    if v.region_name == var.region
  } : {}

  domain_name       = "*.${each.value.domain}"
  validation_method = "DNS"

  tags = {
    Name = "${local.name}-wildcard-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "default_validation" {
  for_each = aws_acm_certificate.default

  name    = tolist(each.value.domain_validation_options)[0].resource_record_name
  type    = tolist(each.value.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.default.zone_id
  ttl     = 300
  records = [tolist(each.value.domain_validation_options)[0].resource_record_value]
}

resource "aws_acm_certificate_validation" "default" {
  for_each = aws_acm_certificate.default

  certificate_arn         = each.value.arn
  validation_record_fqdns = [aws_route53_record.default_validation[each.key].fqdn]
}

data "aws_route53_zone" "default" {
  name = local.domain
}