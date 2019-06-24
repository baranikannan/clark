#------------------------------------------------------------------------------
#   Server Security group relaxed for testing
#------------------------------------------------------------------------------


resource "aws_security_group" "consulsrv" {
  name_prefix = "${var.env}-${var.project}-"
  description = "${var.env} ${var.project}"
  vpc_id      = "${data.aws_vpc.main.id}"

  tags {
    Name        = "${var.env}:${var.project}"
    Environment = "${var.env}"
    Application = "${var.project}"
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#------------------------------------------------------------------------------
#   Roles, Profiles and Policies
#------------------------------------------------------------------------------

data "aws_iam_policy_document" "consul_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "consul_role" {
  name_prefix        = "${var.env}-${var.project}-"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.consul_role.json}"
}



resource "aws_iam_instance_profile" "consul_profile" {
  name_prefix = "${var.env}-=${var.project}-"
  path        = "/"
  role        = "${aws_iam_role.consul_role.name}"
}


data "aws_iam_policy_document" "consul_policy" {
  
#statement for permission to read the tags, so that consul cluster will join together 
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstanceStatus"
    ]

    resources = [
          "*"
    ]
  }

   statement {
    actions = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
    ]

    resources = [
          "arn:aws:s3:::${aws_s3_bucket.s3lifecycle.id}",
          "arn:aws:s3:::${aws_s3_bucket.s3lifecycle.id}/*"
    ]
  }
}

resource "aws_iam_policy" "consul_policy" {
  name_prefix = "${var.env}-${var.project}-"
  path        = "/"
  description = "My test policy"
  policy      = "${data.aws_iam_policy_document.consul_policy.json}"
}

resource "aws_iam_role_policy_attachment" "consul_policy" {
    role       = "${aws_iam_role.consul_role.name}"
    policy_arn = "${aws_iam_policy.consul_policy.arn}"
}


#------------------------------------------------------------------------------
# Launch Config 
#------------------------------------------------------------------------------

resource "aws_launch_configuration" "consul" {
  name_prefix                 = "${var.project}-server"
  image_id                    = "${data.aws_ami.consul.id}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = "false"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.consul_profile.name}"
  security_groups             = ["${aws_security_group.consulsrv.id}"]
  user_data                   = "${data.template_cloudinit_config.cloud_init.rendered}"

  root_block_device {
    volume_size = 20
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Autoscaling group
#------------------------------------------------------------------------------

resource "aws_autoscaling_group" "consul" {
  name_prefix           = "${var.env}-${var.project}-"

  min_size              = "${var.stackMinSize}"
  max_size              = "${var.stackMaxSize}"
  vpc_zone_identifier   = [ "${ data.aws_subnet.tier2.*.id }" ]
  launch_configuration  = "${aws_launch_configuration.consul.name}"
  desired_capacity      = "${ var.stackDesiredSize }"
  target_group_arns        = [ "${aws_alb_target_group.consul_target_group.arn}" ]
  health_check_type     = "ELB"

  enabled_metrics       = [
                            "GroupMinSize",
                            "GroupMaxSize",
                            "GroupDesiredCapacity",
                            "GroupInServiceInstances",
                            "GroupPendingInstances",
                            "GroupStandbyInstances",
                            "GroupTerminatingInstances",
                            "GroupTotalInstances"
                          ]

  tag {
    key                 = "Name"
    value               = "${var.project}-server"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}