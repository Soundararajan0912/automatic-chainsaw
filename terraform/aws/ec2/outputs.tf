# Terraform Outputs

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet Information
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# Load Balancer Information
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}
# EC2 Instance Information
output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.main[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.main[*].private_ip
}

output "instance_availability_zones" {
  description = "Availability zones of the EC2 instances"
  value       = aws_instance.main[*].availability_zone
}

# Security Group Information
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

# IAM Information
output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}

# Network Information
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Access Information
output "ssm_session_manager_url" {
  description = "URL to access instances via SSM Session Manager"
  value       = "https://${var.aws_region}.console.aws.amazon.com/systems-manager/session-manager/start-session"
}

# Application URLs
output "application_url_http" {
  description = "HTTP URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "application_url_https" {
  description = "HTTPS URL to access the application"
  value       = "https://${aws_lb.main.dns_name}"
}

output "jenkins_url" {
  description = "Jenkins URL to access Jenkins dashboard"
  value       = "http://${aws_lb.main.dns_name}:8080"
}

# Backup Information
output "ami_backup_policy_id" {
  description = "ID of the AMI backup lifecycle policy"
  value       = aws_dlm_lifecycle_policy.ami_backup_policy.id
}

output "ebs_snapshot_policy_id" {
  description = "ID of the EBS snapshot lifecycle policy"
  value       = aws_dlm_lifecycle_policy.ebs_snapshot_policy.id
}