output "aws_lambda_function" {
  value = "${aws_lambda_function.ec2state.function_name}"
}

output "aws_cloudwatch_event_rule" {
  value = "${aws_cloudwatch_event_rule.ec2state.name}"
}
