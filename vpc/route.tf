#------------------------------------------------------------------------------
# Routing table creation
#------------------------------------------------------------------------------

resource "aws_route_table" "tier1" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
   gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Tier1"
  }
}

resource "aws_route_table" "tier2a" {
  vpc_id = "${aws_vpc.main.id}"

  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = "${aws_nat_gateway.natgw1.id}"
  }
  tags = {
    Name = "Tier2a"
  }
}

resource "aws_route_table" "tier2b" {
  vpc_id = "${aws_vpc.main.id}"

  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = "${aws_nat_gateway.natgw1.id}"
  }
  tags = {
    Name = "Tier2b"
  }
}
resource "aws_route_table" "tier2c" {
  vpc_id = "${aws_vpc.main.id}"

  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = "${aws_nat_gateway.natgw1.id}"
  }
  tags = {
    Name = "Tier2c"
  }
}


resource "aws_route_table" "tier3" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "Tier3"
  }
}


#------------------------------------------------------------------------------
# Roting table association
#------------------------------------------------------------------------------

resource "aws_route_table_association" "tier1" {
  count = "${length(var.tier1cidr)}"

  subnet_id      = "${element(aws_subnet.tier1.*.id, count.index)}"
  route_table_id = "${aws_route_table.tier1.id}"
}

resource "aws_route_table_association" "tier2a" {
  subnet_id      = "${element(aws_subnet.tier2.*.id, 0)}"
  route_table_id = "${aws_route_table.tier2a.id}"
}
resource "aws_route_table_association" "tier2b" {
  subnet_id      = "${element(aws_subnet.tier2.*.id, 1)}"
  route_table_id = "${aws_route_table.tier2b.id}"
}
resource "aws_route_table_association" "tier2c" {
  subnet_id      = "${element(aws_subnet.tier2.*.id, 2)}"
  route_table_id = "${aws_route_table.tier2c.id}"
}

resource "aws_route_table_association" "tier3" {
  count = "${length(var.tier3cidr)}"

  subnet_id      = "${element(aws_subnet.tier3.*.id, count.index)}"
  route_table_id = "${aws_route_table.tier3.id}"
}

