
#------------------------------------------------------------------------------
# Account 
#------------------------------------------------------------------------------

provider "aws" {
  profile = "${var.organisation}-${var.account}"
  region  = "ap-southeast-1"
}

#------------------------------------------------------------------------------
# VPC creation 
#------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block       = "${var.cidr_block}"
  enable_dns_hostnames = "true"  

  tags = {
	    Name = "${var.organisation}-${var.env}-${data.aws_region.current.name}"
  }
}


#------------------------------------------------------------------------------
# Internet Gateway  
#------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.env}-${data.aws_region.current.name}"
  }
}


#------------------------------------------------------------------------------
# Nat Gateway 
#------------------------------------------------------------------------------

resource "aws_eip" "natgw1" {
    vpc = true
}


resource "aws_nat_gateway" "natgw1" {
  allocation_id = "${aws_eip.natgw1.id}"
  subnet_id     = "${element(aws_subnet.tier1.*.id, 0)}"
tags = {
    Name = "Tier1a-${var.env}-${data.aws_region.current.name}"
  }
}

#------------------------------------------------------------------------------
# DHCP Option set 
#------------------------------------------------------------------------------

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name          = "${var.zone}"
  domain_name_servers  = ["AmazonProvidedDNS"]
  netbios_node_type    = 2

  tags = {
    Name = "${var.env}-${aws_vpc.main.id}"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}


#------------------------------------------------------------------------------
# Private Hosted Zone for all instnaces to map the internal DNS name
#------------------------------------------------------------------------------

resource "aws_route53_zone" "private" {
  name = "${var.zone}"

  vpc {
    vpc_id = "${aws_vpc.main.id}"
  }
}
