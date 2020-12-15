# Configure the AWS Provider
provider "aws" {
    version    = "~> 3.21.0"
    region     = var.region
}


# Create artifact of Lambda function
data "archive_file" "init" {
  type        = "zip"
  source_file = "./function/app.py"
  output_path = "./function/app.zip"
}


# Creat Lambda function
resource "aws_lambda_function" "blockchain" {
    role             = aws_iam_role.lambda_role.arn
    handler          = var.handler
    runtime          = var.runtime
    filename         = "./function/app.zip"
    function_name    = var.function_name
    source_code_hash = filebase64sha256("./function/app.zip")
}

# Basic access policy of Lambda
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name        = "lambda_role"
  path        = "/"
  description = "Allows Lambda Function to call AWS services on your behalf."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}
