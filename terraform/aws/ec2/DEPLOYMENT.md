# AWS Infrastructure Deployment Guide

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **Appropriate AWS permissions** for creating VPC, EC2, IAM, Lambda resources

## Quick Start

1. **Clone and navigate to the directory:**
   ```bash
   cd aws-iac-terraform
   ```

2. **Review and update configuration:**
   ```bash
   # Edit terraform.tfvars with your specific values
   vim terraform.tfvars
   ```

3. **Deploy the infrastructure:**
   ```bash
   # Initialize Terraform
   make init

   # Review the plan
   make plan

   # Apply the configuration
   make apply
   ```

## Configuration

### Key Variables to Update

- `aws_region`: Your preferred AWS region
- `project_name`: Name for your project resources
- `environment`: Environment name (dev, staging, prod)
- `allowed_cidr_blocks`: IP ranges allowed to access the load balancer
- `instance_type`: EC2 instance size
- `key_pair_name`: Optional EC2 key pair for emergency access

### Network Architecture

- **VPC CIDR**: 10.0.0.0/24 (256 IP addresses)
- **Public Subnets**: 10.0.0.0/26, 10.0.0.64/26 (64 IPs each)
- **Private Subnets**: 10.0.0.128/26, 10.0.0.192/26 (64 IPs each)

## Access Methods

### Primary: SSM Session Manager
```bash
# List instances
aws ec2 describe-instances --filters "Name=tag:Project,Values=your-project-name"

# Start SSM session
aws ssm start-session --target i-1234567890abcdef0
```

### Application Access
- **HTTP**: http://[load-balancer-dns-name]
- **HTTPS**: https://[load-balancer-dns-name]

## Security Features

- ✅ No public IP addresses on EC2 instances
- ✅ Private subnets for compute resources
- ✅ NAT Gateway for secure outbound access
- ✅ Security groups with minimal required access
- ✅ SSM Session Manager for secure shell access
- ✅ EBS encryption enabled
- ✅ Termination protection enabled

## Backup Strategy

### Automated Backups
- **EBS Snapshots**: Daily at 3:00 AM UTC, 7-day retention (AWS DLM)
- **AMI Creation**: Daily at 2:00 AM UTC, 7-day retention (AWS DLM)
- **AWS Data Lifecycle Manager**: Handles both AMI and snapshot creation/cleanup

### Manual Backup
```bash
# Create manual AMI
aws ec2 create-image --instance-id i-1234567890abcdef0 --name "manual-backup-$(date +%Y%m%d)"
```

## Monitoring and Maintenance

### Health Checks
```bash
# Check instance status
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0

# Check load balancer health
aws elbv2 describe-target-health --target-group-arn [target-group-arn]
```

### Backup Management
```bash
# View DLM policies
aws dlm get-lifecycle-policies

# View AMI backups
aws ec2 describe-images --owners self --filters "Name=tag:SnapshotCreator,Values=DLM-AMI"

# View EBS snapshots
aws ec2 describe-snapshots --owner-ids self --filters "Name=tag:SnapshotCreator,Values=DLM"
```

## Troubleshooting

### Common Issues

1. **SSM Access Not Working**
   - Verify VPC endpoints are created
   - Check security group allows HTTPS (443) from VPC CIDR
   - Ensure IAM role has SSM permissions

2. **Load Balancer Health Check Failing**
   - Verify Nginx is running on instances
   - Check security group allows traffic from ALB
   - Review target group health check settings

3. **Instance Not Starting**
   - Check user data script logs: `/var/log/user-data.log`
   - Verify IAM instance profile permissions
   - Review CloudWatch logs

### Useful Commands
```bash
# SSH to instance via SSM
aws ssm start-session --target i-1234567890abcdef0

# Check services on instance
sudo systemctl status docker nginx amazon-ssm-agent

# View user data execution
sudo cat /var/log/user-data.log

# Check Docker status
sudo docker ps
```

## Cleanup

To destroy all resources:
```bash
make destroy
```

**Warning**: This will permanently delete all resources including backups.

## Cost Optimization

- Use appropriate instance types for your workload
- Consider using Spot instances for non-production environments
- Review and adjust backup retention periods
- Monitor unused resources with AWS Cost Explorer