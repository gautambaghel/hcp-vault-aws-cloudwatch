data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

provider "aws" {
  region = var.region
}

resource "aws_iam_user" "hcp_user" {
  name = "demo-${var.user_email}-vault-monitoring"

  # We need the DemoUser policy assigned to an IAM user, to comply with our AWS
  # Service Control Policy (SCP)
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true

  tags = {
    hcp-org-id     = var.hcp_org_id
    hcp-project-id = var.hcp_project_id
  }
}

# Policies for Audits
# https://developer.hashicorp.com/vault/tutorials/cloud-monitoring/vault-audit-log-cloudwatch
# (Metrics, not yet available in the Permissions Boundary)

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
  user    = aws_iam_user.hcp_user.name
}

output "id" {
  value = aws_iam_access_key.access_key.id
}

output "secret" {
  value = aws_iam_access_key.access_key.secret
  sensitive = true
}
