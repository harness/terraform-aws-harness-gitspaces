resource "aws_route53_zone" "default" {
  name = local.domain
  tags = {
    Name = "${local.name}-dns-zone"
  }
}