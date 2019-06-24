

data "aws_caller_identity" "current" {}

data "aws_region" "current" { }

#------------------------------------------------------------------------------
#   Region and Zones
#------------------------------------------------------------------------------

variable "suffixes" {
  default = {
    "0" = "a"
    "1" = "b"
    "2" = "c"
    "3" = "d"
  }
}


data "aws_availability_zone" "zones" {
  count = "3"
  name = "${data.aws_region.current.name}${lookup(var.suffixes, count.index)}"
}  

#------------------------------------------------------------------------------
#   VPC and Subnets
#------------------------------------------------------------------------------

data "aws_vpc" "main" {
  tags {
    Name = "${var.organisation}-${var.env}-${data.aws_region.current.name}"
  }
}

data "aws_subnet" "tier1" {
  count  = 3
  vpc_id = "${ data.aws_vpc.main.id }"
  availability_zone = "${ element( data.aws_availability_zone.zones.*.id, count.index ) }"

  tags {
    Tier = "1"
  }
}
data "aws_subnet" "tier2" {
  count  = 3
  vpc_id = "${ data.aws_vpc.main.id }"
  availability_zone = "${ element( data.aws_availability_zone.zones.*.id, count.index ) }"

  tags {
    Tier = "2"
  }
}
data "aws_subnet" "tier3" {
  count  = 3
  vpc_id = "${ data.aws_vpc.main.id }"
  availability_zone = "${ element( data.aws_availability_zone.zones.*.id, count.index ) }"

  tags {
    Tier = "3"
  }
}


#------------------------------------------------------------------------------
#   AMI's Most recent
#------------------------------------------------------------------------------

data "aws_ami" "consul" {
  most_recent = "true"
  owners      = ["945251900491"]
  name_regex  = "^${var.project}-*"
}

#------------------------------------------------------------------------------
#   Cloud-init data
#------------------------------------------------------------------------------

data "template_file" "init_script" {
  template = "${file("${path.module}/files/init.sh")}"

}


data "template_file" "cloud_config" {
  template = "${file("${path.module}/files/cloud-config.tpl")}"

  vars {
    shellscript = "${base64encode( data.template_file.backup.rendered )}"
  }
}

data "template_file" "backup" {
  template = "${file("${path.module}/files/backup.sh")}"

  vars {
    env                 = "${var.env}"
  }
}



data "template_cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloud_config.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.init_script.rendered}"
  }
}