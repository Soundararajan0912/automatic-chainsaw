# Terraform Variables Configuration
# Update these values according to your requirements

aws_region   = "us-west-2"
project_name = "my-aws-infrastructure"
environment  = "dev"

# Network Configuration
vpc_cidr             = "10.0.0.0/24"
availability_zones   = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs  = ["10.0.0.0/26", "10.0.0.64/26"]
private_subnet_cidrs = ["10.0.0.128/26", "10.0.0.192/26"]

# EC2 Configuration
instance_type    = "t3.medium"
instance_count   = 1
root_volume_size = 50

# Optional: EC2 Key Pair (SSM is primary access method)
key_pair_name = ""

# Security Configuration - Load Balancer Access
allowed_cidr_blocks = ["0.0.0.0/0"] # IMPORTANT: Restrict this to your IP ranges in production



# Backup Configuration
backup_retention_days         = 7
enable_termination_protection = true

# Resource Tags
tags = {
  Terraform   = "true"
  Environment = "dev"
  Project     = "my-aws-infrastructure"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
}