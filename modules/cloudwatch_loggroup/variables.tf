# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


variable "cloudwatch_loggroup" {
  description = "Configuration settings for CloudWatch LogGroup."
  type = object({
    loggroup_name             = string
    iam_role_name             = string
    iam_role_path             = string
    iam_role_pb               = string
    retention_in_days         = number
    kms_principal_permissions = list(string) # should override the statement_id 'PrincipalPermissions'
    monitoring = object({
      inbound_iam_role_name = string
      destination_arn       = string
    })
  })
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
}
