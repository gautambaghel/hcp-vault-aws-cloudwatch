provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Optional: If the IAM policy doesn't exist please remove this block and permissions_boundary below
data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

resource "aws_iam_user" "hcp_user" {
  name = "demo-${var.user_email}-vault-monitoring"

  # Optional: Configure permissions boundary based on the org policies
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true

  tags = {
    hcp-org-id     = var.hcp_org_id
    hcp-project-id = var.hcp_project_id
  }
}

# Policies for Audits
# https://developer.hashicorp.com/vault/tutorials/cloud-monitoring/vault-audit-log-cloudwatch
data "aws_iam_policy_document" "hcp_cloudwatch_logs" {
  statement {
    sid = "HCPLogStreaming"
    actions = [
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:TagLogGroup"
    ]

    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:hashicorp/${var.hcp_org_id}/${var.hcp_project_id}",
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:hashicorp/${var.hcp_org_id}/${var.hcp_project_id}:*"
    ]
  }
}

resource "aws_iam_policy" "audit" {
  name        = "hcp-audit"
  description = "https://developer.hashicorp.com/vault/tutorials/cloud-monitoring/vault-audit-log-cloudwatch"
  policy      = data.aws_iam_policy_document.hcp_cloudwatch_logs.json
}

resource "aws_iam_policy_attachment" "audit" {
  name       = "audit"
  users      = [aws_iam_user.hcp_user.name]
  policy_arn = aws_iam_policy.audit.arn
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.hcp_user.name
}

output "id" {
  value = aws_iam_access_key.access_key.id
}

output "secret" {
  value     = aws_iam_access_key.access_key.secret
  sensitive = true
}
