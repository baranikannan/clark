

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

data "aws_availability_zones" "zones" { }
  







