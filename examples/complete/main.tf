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
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "core_logging" {
  provider = aws.core_logging
}

data "aws_caller_identity" "org_mgmt" {
  provider = aws.org_mgmt
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ RANDOM_STRING
# ---------------------------------------------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CREATE PROVISIONERS
# ---------------------------------------------------------------------------------------------------------------------
# Org-mgmt provisioner: deploys the Organization CloudTrail and CloudWatch LogGroup.
module "create_provisioner_admin" {
  source = "../../cicd-principals/terraform/admin"

  iam_role_settings = {
    name = "org_cloudtrail_admin_cicd_provisioner"
    aws_trustee_arns = [
      "arn:${var.aws_partition}:iam::${var.account_ids.org_mgmt}:root"
    ]
  }
  providers = {
    aws = aws.org_mgmt
  }
}

# Core-logging provisioner: deploys the CloudTrail S3 log archive bucket.
module "create_provisioner_bucket" {
  source = "../../cicd-principals/terraform/bucket"

  iam_role_settings = {
    name = "org_cloudtrail_bucket_cicd_provisioner"
    aws_trustee_arns = [
      "arn:${var.aws_partition}:iam::${var.account_ids.org_mgmt}:root"
    ]
  }
  providers = {
    aws = aws.core_logging
  }
}

# Region-pinned providers, each assuming the corresponding provisioner role.
provider "aws" {
  region = var.aws_region
  alias  = "org_cloudtrail_admin"
  assume_role {
    role_arn = module.create_provisioner_admin.iam_role_arn
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "org_cloudtrail_bucket"
  assume_role {
    role_arn = module.create_provisioner_bucket.iam_role_arn
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "org_cloudtrail_kms" {
  #checkov:skip=CKV_AWS_109 : Resource policy
  #checkov:skip=CKV_AWS_111 : Resource policy
  #checkov:skip=CKV_AWS_356 : Resource policy
  statement {
    sid    = "PrincipalPermissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${var.aws_partition}:iam::${data.aws_caller_identity.org_mgmt.account_id}:root",
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "example_complete" {
  source = "../../"

  org_cloudtrail_name = "organization-cloudtrail"

  cloudwatch_loggroup = {
    kms_principal_permissions = [data.aws_iam_policy_document.org_cloudtrail_kms.json]
  }
  s3_bucket = {
    bucket_name        = "org-cloudtrail-${random_string.suffix.result}"
    days_to_expiration = 3
    force_destroy      = true
  }
  providers = {
    aws.org_cloudtrail_admin  = aws.org_cloudtrail_admin
    aws.org_cloudtrail_bucket = aws.org_cloudtrail_bucket
  }
  depends_on = [
    module.create_provisioner_admin,
    module.create_provisioner_bucket,
  ]
}
