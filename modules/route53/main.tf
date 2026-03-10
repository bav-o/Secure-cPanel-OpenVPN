resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name = var.domain_name
  tags = var.tags
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
}

resource "aws_route53_record" "vpn" {
  zone_id = local.zone_id
  name    = "vpn.${var.domain_name}"
  type    = "A"
  ttl     = var.ttl
  records = [var.vpn_public_ip]
}

resource "aws_route53_record" "cpanel" {
  zone_id = local.zone_id
  name    = "cpanel.${var.domain_name}"
  type    = "A"
  ttl     = var.ttl
  records = [var.cpanel_private_ip]
}
