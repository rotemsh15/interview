## AWS Credentials ##

variable "awsAccessKey" {}
variable "awsSecretKey" {}
variable "awsRegion" {}

## AWS Credentials ##

resource "aws_s3_bucket" "nice-devops-interview-rotem" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_notification" "my-trigger" {
  bucket = aws_s3_bucket.nice-devops-interview-rotem.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-nice-devops-interview-rotem.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = "parse_me.txt"
  }
  depends_on = [
    aws_lambda_function.lambda-nice-devops-interview-rotem,
    aws_s3_bucket.nice-devops-interview-rotem
  ]
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_s3_inline" {
  name = "lambda-s3-inline"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::nice-devops-interview-rotem/*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
  depends_on = [aws_iam_role.lambda_role]
}

resource "aws_iam_role" "lambda_role" {
  name               = "rotem-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "./code/${var.filename}.py"
  output_path = "${var.filename}.zip"
}

resource "aws_lambda_function" "lambda-nice-devops-interview-rotem" {
  function_name    = var.lambda_function_name
  filename         = "./${var.filename}.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"
  handler          = "${var.filename}.lambda_handler"
  timeout          = 10
}

resource "aws_lambda_permission" "invocation_permissions" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-nice-devops-interview-rotem.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::nice-devops-interview-rotem"
}
