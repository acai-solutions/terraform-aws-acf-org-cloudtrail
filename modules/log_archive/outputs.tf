# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


output "bucket_id" {
  description = "Bucket ID of the CloudTrail bucket"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "bucket_arn" {
  description = "ARN of the CloudTrail bucket"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "kms_cmk_arn" {
  description = "ARN of the KMS CMK for encrypting the logs"
  value       = aws_kms_key.core_logging_cloudtrail_mgmt_kms.arn
}

output "sns_topic_arn" {
  description = "ARN of the optional SNS topic"
  value       = var.s3_bucket.notification_to_sns != null ? aws_sns_topic.s3_notification_sns[0].arn : "n/a"
}
