
#------------------------------------------------------------------------------
#   Region and Zones
#------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" { }

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


data "aws_route53_zone" "internal" {
  name         = "${var.zone}"
  private_zone = true
}