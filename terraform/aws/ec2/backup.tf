# Backup Configuration using AWS Data Lifecycle Manager

# AMI Lifecycle Policy for automated AMI creation and cleanup
resource "aws_dlm_lifecycle_policy" "ami_backup_policy" {
  description        = "AMI backup lifecycle policy for ${var.project_name}-${var.environment}"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]
    target_tags = {
      Project     = var.project_name
      Environment = var.environment
    }

    schedule {
      name = "Daily AMI backup"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["02:00"] # 2 AM UTC
      }

      retain_rule {
        count = var.backup_retention_days
      }

      tags_to_add = merge(local.common_tags, {
        SnapshotCreator = "DLM-AMI"
        BackupType      = "AMI"
      })

      copy_tags = true
    }
  }

  tags = local.common_tags
}