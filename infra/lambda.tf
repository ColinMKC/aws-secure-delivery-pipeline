# Stage 4 — created only once the pipeline has pushed a first image (set var.image_uri).

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "secure-delivery-app-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "app" {
  #checkov:skip=CKV_AWS_117:No VPC resources to reach; a VPC adds NAT cost with no security gain here
  #checkov:skip=CKV_AWS_116:Synchronous invoke only; a DLQ applies to async events
  #checkov:skip=CKV_AWS_272:Lambda code signing supports .zip only; image integrity enforced by cosign verify in CI
  #checkov:skip=CKV_AWS_173:No secrets in env vars (APP_VERSION only); CMK would cost ~$1/mo
  count         = var.image_uri == "" ? 0 : 1
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = var.image_uri
  timeout       = 5
  memory_size   = 128

  reserved_concurrent_executions = 2 # caps blast radius (and bill) if abused

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = { APP_VERSION = "stage4" }
  }

  # The pipeline owns code updates after creation; don't fight it.
  lifecycle {
    ignore_changes = [image_uri]
  }
}
