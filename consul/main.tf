
#------------------------------------------------------------------------------
# Account 
#------------------------------------------------------------------------------

provider "aws" {
  profile = "${var.organisation}-${var.account}"
  region  = "ap-southeast-1"
}


#------------------------------------------------------------------------------
# Backup S3 Bucket and policy for lifecycle
#------------------------------------------------------------------------------


resource "aws_s3_bucket" "s3lifecycle" {
  bucket = "clark-consul-${var.env}-backup-987"
  acl    = "private"

  lifecycle_rule {
    id      = "archive"
    enabled = true

    prefix = "archive/"

    tags {
      "rule" = "archive"
    }

    expiration {
      days = 120
    }
  }
}


#------------------------------------------------------------------------------
#ALB DNS mappings
#------------------------------------------------------------------------------

data "null_data_source" "dns_zone" {
    inputs {
        value = "${var.organisation}.${var.account}"
    }   
}


data "aws_route53_zone" "private" {
  name         = "${data.null_data_source.dns_zone.inputs.value}"
  private_zone = true
}


resource "aws_route53_record" "nlb" {
  zone_id = "${data.aws_route53_zone.private.zone_id}"
  name    = "consul.${data.null_data_source.dns_zone.inputs.value}"
  type    = "A"

  alias {
    name                   = "${aws_alb.consul.dns_name}"
    zone_id                = "${aws_alb.consul.zone_id}"
    evaluate_target_health = false
  }
}