# Stage 5 — T7: detection-as-code. Alert if anyone modifies the deploy role.
# TODO (Stage 5): confirm the SNS subscription email, then test by attaching a
# policy to the role in the console. Screenshot the alert for the README.

resource "aws_sns_topic" "alerts" {
  #checkov:skip=CKV_AWS_26:EventBridge can't publish to topics encrypted with the AWS-managed SNS key; CMK costs ~$1/mo
  provider = aws.us_east_1
  name     = "secure-delivery-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  provider  = aws.us_east_1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "deploy_role_tampering" {
  provider    = aws.us_east_1
  name        = "deploy-role-tampering"
  description = "IAM change to the GitHub deploy role (privilege escalation / persistence)"
  event_pattern = jsonencode({
    source        = ["aws.iam"]
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
      eventName = [
        "UpdateAssumeRolePolicy",
        "PutRolePolicy",
        "AttachRolePolicy",
        "DeleteRolePolicy",
        "DetachRolePolicy",
      ]
      requestParameters = { roleName = [aws_iam_role.deploy.name] }
    }
  })
}

resource "aws_cloudwatch_event_target" "to_sns" {
  provider = aws.us_east_1
  rule     = aws_cloudwatch_event_rule.deploy_role_tampering.name
  arn      = aws_sns_topic.alerts.arn
  # TODO (stretch): input_transformer for a human-readable alert (who, what, from where)
}

data "aws_iam_policy_document" "sns_from_events" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.deploy_role_tampering.arn]
    }
  }
}

resource "aws_sns_topic_policy" "alerts" {
  provider = aws.us_east_1
  arn      = aws_sns_topic.alerts.arn
  policy   = data.aws_iam_policy_document.sns_from_events.json
}
