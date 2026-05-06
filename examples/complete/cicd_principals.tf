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
# ¦ CREATE PROVISIONER
# ---------------------------------------------------------------------------------------------------------------------
# Org-mgmt provisioner: deploys the Organization CloudTrail and CloudWatch LogGroup.
module "create_provisioner_admin" {
  source = "../../cicd-principals/terraform/admin"

  iam_role_settings = {
    name = "org_cloudtrail_admin_cicd_provisioner"
    aws_trustee_arns = [
      "arn:${data.aws_partition.current.partition}:iam::${var.account_ids.org_mgmt}:root"
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
      "arn:${data.aws_partition.current.partition}:iam::${var.account_ids.org_mgmt}:root"
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
