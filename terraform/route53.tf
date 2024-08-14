resource "aws_route53_record" "fastapi" {
  zone_id = var.zone_id
  name    = "fastapi"
  type    = "CNAME"
  ttl     = 5
  records = [aws_lb.ecs_alb.dns_name]
}