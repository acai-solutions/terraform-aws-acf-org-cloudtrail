# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


output "iam_role_arn" {
  description = "ARN of the IAM Role used to push CLoudTrail Logs to CloudWatch"
  value       = aws_iam_role.org_cloudtrail_cloudwatch_logs.arn
}

output "loggroup_arn" {
  description = "ARN of the CloudWatch LogGroup"
  value       = aws_cloudwatch_log_group.org_cloudtrail_cloudwatch_loggroup.arn
}

output "kms_cmk_arn" {
  description = "ARN of the KMS CMK used to encrypt the CloudWatch Logs"
  value       = aws_kms_key.org_cloudtrail_kms.arn
}
