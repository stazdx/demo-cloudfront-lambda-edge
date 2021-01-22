resource "aws_iam_role" "lambda_edge_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_edge" {
  handler       = "index.handler"
  filename      = "lambda_function.zip"
  function_name = "cf-demo"
  description   = "cloudfront & Lambda Edge"
  role          = aws_iam_role.lambda_edge_exec.arn
  runtime       = "nodejs12.x"
  publish       = true

  tags = {
    Name = "cf-demo"
  }
}