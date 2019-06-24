#------------------------------------------------------------------------------
#  main.tf
#------------------------------------------------------------------------------

provider "aws" {
  profile = "${var.organisation}-${var.account}"
  region  = "ap-southeast-1"
}



#------------------------------------------------------------------------------
#   Roles, Profiles and Policies
#------------------------------------------------------------------------------

# Lambda Policy  
resource "aws_iam_role" "ec2state" {
  name                = "${var.project}-ec2state-lambda"
  assume_role_policy  = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_policy" "ec2state" {
    name   = "${var.project}-ec2state-lambda"
    path   = "/"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:*:*:*",
                "arn:aws:route53:::hostedzone/${data.aws_route53_zone.internal.zone_id}",
                "arn:aws:ec2:*:*:instance/*"
            ],
            "Action": [
                "logs:CreateLogStream",
                "ec2:DeleteTags",
                "ec2:CreateTags",
                "route53:ChangeResourceRecordSets",
                "logs:PutLogEvents",
                "logs:CreateLogGroup"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "ec2:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteNetworkInterface"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "ec2state" {
  name       = "${var.project}-ec2state-lambda"
  roles      = ["${aws_iam_role.ec2state.name}"]
  policy_arn = "${aws_iam_policy.ec2state.arn}"
}



#------------------------------------------------------------------------------
# Lambda function
#------------------------------------------------------------------------------

resource "aws_lambda_function" "ec2state" {
    filename          = "files/ec2state.zip"
    function_name     = "${var.project}-ec2state"
    runtime           = "python3.7"
    timeout           = "240"
    role              = "${aws_iam_role.ec2state.arn}"
    handler           = "ec2state.lambda_handler"
    source_code_hash  = "${base64sha256(file("files/ec2state.zip"))}"
    vpc_config        = {
      subnet_ids = ["${data.aws_subnet.tier2.*.id}"]
      security_group_ids = ["${aws_security_group.ec2state.id}"]
      }

    environment {
      variables = {
        ENVIRONMENT = "${var.grp}"
        NAME        = "${var.project}-ec2state"
      }
    }
  }


#------------------------------------------------------------------------------
# Cloudwatch Event, triggers and permission
#------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "ec2state" {
  name        = "capture-ec2-scaling-events"
  description = "Capture all EC2 scaling events"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "running",
      "terminated"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
    rule = "${aws_cloudwatch_event_rule.ec2state.name}"
    target_id = "ec2state"
    arn = "${aws_lambda_function.ec2state.arn}"
}


resource "aws_security_group" "ec2state" {
  name        = "${var.project}-ec2state-lambda"
  description = "${var.project}  lambda"
  vpc_id      = "${data.aws_vpc.main.id}"

  tags {
    Name        = "${var.project}-ec2state-lambda"
    Environment = "${var.grp}"
    Application = "${var.project}"
    Role        = "lambda"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lambda_permission" "ec2state" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ec2state.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2state.arn}"
#  qualifier     = "${aws_lambda_alias.test_alias.name}"
}

