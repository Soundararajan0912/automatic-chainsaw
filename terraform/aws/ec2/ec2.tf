# EC2 Instance Configuration

# EC2 Instances
resource "aws_instance" "main" {
  count = var.instance_count

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name != "" ? var.key_pair_name : null
  subnet_id                   = aws_subnet.private[count.index % length(aws_subnet.private)].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  disable_api_termination     = var.enable_termination_protection
  user_data                   = base64encode(file("${path.module}/user_data.sh"))

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = false  # Temporarily disabled due to KMS key issue
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-volume-${count.index + 1}"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-instance-${count.index + 1}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EBS Snapshot Lifecycle Policy
resource "aws_dlm_lifecycle_policy" "ebs_snapshot_policy" {
  description        = "EBS snapshot lifecycle policy for ${var.project_name}-${var.environment}"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]
    target_tags = {
      Project     = var.project_name
      Environment = var.environment
    }

    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = var.backup_retention_days
      }

      tags_to_add = merge(local.common_tags, {
        SnapshotCreator = "DLM"
      })

      copy_tags = true
    }
  }

  tags = local.common_tags
}

# IAM Role for DLM
resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "${var.project_name}-${var.environment}-dlm-lifecycle-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM Policy for DLM
resource "aws_iam_role_policy" "dlm_lifecycle_policy" {
  name = "${var.project_name}-${var.environment}-dlm-lifecycle-policy"
  role = aws_iam_role.dlm_lifecycle_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes"
        ]
        Resource = "*"
      }
    ]
  })
}