#------------------------------------------------------------------------------
# Subnet defined 
#------------------------------------------------------------------------------

resource "aws_subnet" "tier1" {
  count             = "${length(data.aws_availability_zones.zones.names)}"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.zones.names, count.index)}"
  cidr_block        = "${lookup(var.tier1cidr, count.index)}"
  map_public_ip_on_launch = "true"

  lifecycle {
    #    prevent_destroy = true
  }
  tags {
    Tier = "1"
    Name="public-${var.grp}-tier1${lookup(var.suffixes, count.index)}-${data.aws_region.current.name}${lookup(var.suffixes, count.index)}"
  }
}


resource "aws_subnet" "tier2" {
  count             = "${length(data.aws_availability_zones.zones.names)}"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.zones.names, count.index)}"
  cidr_block        = "${lookup(var.tier2cidr, count.index)}"


  lifecycle {
    #    prevent_destroy = true
  }
  tags {
    Tier = "2"
    Name="private-${var.grp}-tier2${lookup(var.suffixes, count.index)}-${data.aws_region.current.name}${lookup(var.suffixes, count.index)}"
  }
}


resource "aws_subnet" "tier3" {
  count             = "${length(data.aws_availability_zones.zones.names)}"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.zones.names, count.index)}"
  cidr_block        = "${lookup(var.tier3cidr, count.index)}"


  lifecycle {
    #    prevent_destroy = true
  }
  tags {
    Tier = "3"
    Name="private-${var.grp}-tier3${lookup(var.suffixes, count.index)}-${data.aws_region.current.name}${lookup(var.suffixes, count.index)}"
  }
}
