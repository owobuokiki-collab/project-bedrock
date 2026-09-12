# 1. Developer IAM User
resource "aws_iam_user" "dev_view" {
  name = "bedrock-dev-view"

  tags = {
    Project = "tinyuka-2025-capstone"
  }
}

# 2. Access Keys for Grading Deliverable
resource "aws_iam_access_key" "dev_view_key" {
  user = aws_iam_user.dev_view.name
}

# 3. AWS Managed ReadOnlyAccess Policy
resource "aws_iam_user_policy_attachment" "dev_view_readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# 4. S3 PutObject Permission (Required for Section 4.3 / 4.5)
resource "aws_iam_user_policy" "dev_view_s3_put" {
  name = "bedrock-dev-s3-put-policy"
  user = aws_iam_user.dev_view.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["arn:aws:s3:::bedrock-assets-*/*"]
      }
    ]
  })
}

# 5. EKS Access Entry
resource "aws_eks_access_entry" "dev_view" {
  cluster_name  = "project-bedrock-cluster"
  principal_arn = aws_iam_user.dev_view.arn
  type          = "STANDARD"
}

# 6. EKS Policy Association (AmazonEKSViewPolicy scoped to retail-app)
resource "aws_eks_access_policy_association" "dev_view_policy" {
  cluster_name  = "project-bedrock-cluster"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_iam_user.dev_view.arn

  access_scope {
    type       = "namespace"
    namespaces = ["retail-app"]
  }

  depends_on = [aws_eks_access_entry.dev_view]
}

# Generate a console password for bedrock-dev-view
resource "aws_iam_user_login_profile" "dev_view_login" {
  user                    = aws_iam_user.dev_view.name
  password_reset_required = false
}
