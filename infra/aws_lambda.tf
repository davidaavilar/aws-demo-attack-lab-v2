resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.deployment_name}-${random_string.unique_id.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "analysis_lambda" {
  # lambda have plain text secrets in environment variables
  filename      = "${path.root}/resources/lambda_function_payload.zip"
  function_name = "${var.deployment_name}-${random_string.unique_id.result}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function_payload.lambda_handler"
  layers        = [ "arn:aws:lambda:us-east-1:108863513136:layer:requests-layer:7" ]

  source_code_hash = filebase64sha256("${path.root}/resources/lambda_function_payload.py")

  runtime = "python3.9"

  environment {
    variables = {
      access_key = "AKIAIOSFODNN7EXAMPLE1"
      secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    }
  }
  tracing_config {
    mode = "PassThrough"
  }
}