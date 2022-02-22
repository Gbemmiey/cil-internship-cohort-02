terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
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

resource "aws_lambda_function" "python_lambda" {
  handler       = "index.printHello"
  role          = "aws_iam_role.iam_for_lambda.arn"
  runtime       = "python3.6"
  function_name = "python_lambda"
}


resource "aws_iam_role" "step_function_role" {
  name               = "step_function_role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "StepFunctionAssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "step_function_policy" {
  name = "step_function_policy"
  role = aws_iam_role.step_function_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "lambda:InvokeFunction",
        "Effect": "Allow",
        "Resource": "aws_lamba_function.python_lambda.arn"
      }
    ]
  }
  EOF
}

resource "aws_sfn_state_machine" "step_function" {
  name     = "step_function"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
  {
    "StartAt": "HelloPy",
    "States": {
      "HelloPy": {
        "Type": "Task",
        "Resource": aws_lambda_function.python_lambda.arn
        "End": true
      }
    }
  }
  EOF
}
