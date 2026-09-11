locals {
  project_name = "project-bedrock"

  common_tags = {
    Project = "tinyuka-2025-capstone"
  }
}


resource "aws_budgets_budget" "cost_alert" {
  name         = "project-bedrock-budget"
  budget_type  = "COST"
  limit_amount = "20"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}

# ------------------------------------------------------------------------------
# 1. Random String for Unique S3 Bucket Suffix
# ------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ------------------------------------------------------------------------------
# 2. S3 Bucket (Assets)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "assets" {
  bucket        = "bedrock-assets-${random_string.suffix.result}"
  force_destroy = true

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# 3. Lambda IAM Role & Policies
# ------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "bedrock-asset-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Scope S3 access to only reading the assets bucket
resource "aws_iam_policy" "lambda_s3_read" {
  name        = "bedrock-asset-processor-s3-read"
  description = "Allows Lambda to read objects from the assets bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "${aws_s3_bucket.assets.arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_read.arn
}


