# Configure the AWS Provider
provider "aws" {
    version    = "~> 3.21.0"
    region     = var.region
}


# Create SNS Topic
resource "aws_sns_topic" "block_updates" {
  name = "block-topic"
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
   
    environment {
        variables = {
            sns_topic = aws_sns_topic.block_updates.arn
        }
    }
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

# Allow Lambda send message to SNS topic
data "aws_iam_policy_document" "lambda_sns_policy" {
    statement {
        actions = ["sns:Publish"]
        resources = [
            aws_sns_topic.block_updates.arn,
        ]
    }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_sns_policy.json
}


# Output app address
output "sns_arn" {
    value       = aws_sns_topic.block_updates.arn
    description = "SNS topic ARN"
}
