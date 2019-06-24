output "aws_vpc" {
  value = "${aws_vpc.main.id}"
}

output "aws_route53_zone" {
  value = "${aws_route53_zone.private.name}"
}