data "aws_route53_zone" "webapplication"{
    name = "${var.profile}.${var.domain_name}"
    private_zone = false
}

resource "aws_eip" "lb" {
  instance = aws_instance.demo.id
  vpc = true
}

resource "aws_route53_record" "webapplication" {
    zone_id = data.aws_route53_zone.webapplication.zone_id
    name = "${var.profile}.${var.domain_name}"
    type = "A"
    ttl = 60
    records = [aws_eip.lb.public_ip]
}