# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
#
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


# ---------------------------------------------------------------------------------------------------------------------
# ¦ VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.30"
      configuration_aliases = []
    }
  }
}

data "aws_partition" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ IAM ROLE - ORG CLOUDTRAIL BUCKET PROVISIONER
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "cicd_principal" {
  name                 = var.iam_role_settings.name
  path                 = var.iam_role_settings.path
  permissions_boundary = var.iam_role_settings.permissions_boundary_arn
  description          = "IAM Role used to provision the Organization CloudTrail Log Bucket (core-logging account)"
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy.json
  tags                 = var.resource_tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = var.iam_role_settings.aws_trustee_arns
    }
  }
}

resource "aws_iam_role_policy" "org_cloudtrail_bucket" {
  name   = "OrgCloudTrailBucketProvisioning"
  role   = aws_iam_role.cicd_principal.id
  policy = data.aws_iam_policy_document.org_cloudtrail_bucket.json
}

#tfsec:ignore:AVD-AWS-0057
#trivy:ignore:AVD-AWS-0345
data "aws_iam_policy_document" "org_cloudtrail_bucket" {
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_356
  #checkov:skip=CKV_AWS_109
  statement {
    sid    = "OrganizationRead"
    effect = "Allow"
    actions = [
      "organizations:DescribeOrganization",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "S3BucketManagement"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::*",
    ]
  }
  statement {
    sid    = "KMSManagement"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "SNSManagement"
    effect = "Allow"
    actions = [
      "sns:*",
    ]
    resources = ["*"]
  }
}
