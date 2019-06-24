#------------------------------------------------------------------------------
#   NLB
#------------------------------------------------------------------------------

resource "aws_alb" "consul" {
  name                = "${var.env}-consul-NLB"
  subnets             = ["${data.aws_subnet.tier2.*.id}"]
  internal            = "true"
  load_balancer_type  = "network"

  tags {
    Name              = "${var.env}-consul-NLB"
    Environment       = "${var.env}"
    Application       = "consul"
    Role              = "nlb"
  }
}

#------------------------------------------------------------------------------
#   NLB Target Group
#------------------------------------------------------------------------------

resource "aws_alb_target_group" "consul_target_group" {
  name                 = "${var.env}-consul"
  vpc_id               = "${data.aws_vpc.main.id}"
  port                 = "8500"
  protocol             = "TCP"

  health_check {
    interval            = "30"
    port                = "traffic-port"
    healthy_threshold   = "10"
    unhealthy_threshold = "10"
    protocol            = "TCP"
  }

  tags {
    Name        = "${var.env}-consul-NLB"
    Environment = "${var.env}"
    Application = "consul"
  }

}

#------------------------------------------------------------------------------
#   NLB Listener
#------------------------------------------------------------------------------

resource "aws_alb_listener" "frontend" {
  load_balancer_arn = "${aws_alb.consul.arn}"
  port              = "8500"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.consul_target_group.arn}"
    type             = "forward"
  }

}

