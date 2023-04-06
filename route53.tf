data "aws_route53_zone" "webapplication" {
  name         = "${var.profile}.${var.domain_name}"
  private_zone = false
}

# resource "aws_eip" "lb" {
#   instance = aws_instance.demo.id
#   vpc      = true
# }

resource "aws_route53_record" "webapplication" {
  zone_id = data.aws_route53_zone.webapplication.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.application_loadbalancer.dns_name
    zone_id                = aws_lb.application_loadbalancer.zone_id
    evaluate_target_health = true
  }
}
output "test" {
  value = aws_lb.application_loadbalancer.dns_name
}