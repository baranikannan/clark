output "ami_id" {
  value = "${data.aws_ami.consul.id}"
}

output "alb_public_dns_name" {
  value = "${aws_alb.consul.dns_name }"
}

output "elb_private_id" {
  value = "${aws_alb.consul.id}"
}

output "asg_id" {
  value = "${aws_autoscaling_group.consul.id}"
}


output "s3_bucket_domain_name" {
  value = "${aws_s3_bucket.s3lifecycle.bucket_domain_name}"
  }


output "aws_alb" {
  value = "${aws_alb.consul.id}"
}

output "aws_route53_record" {
  value = "${aws_route53_record.nlb.name}"
}