# AWS Infrastructure as Code - Terraform

Complete AWS infrastructure setup with VPC, private subnets, NAT Gateway, Application Load Balancer, and EC2 instances running Docker and Nginx.

## 🏗️ Architecture Overview

```
Internet Gateway
    ↓
Public Subnets (10.0.0.0/26, 10.0.0.64/26)
    ├── Application Load Balancer (ports 80/443/8080)
    └── NAT Gateway
        ↓
Private Subnets (10.0.0.128/26, 10.0.0.192/26)
    └── EC2 Instances (no public IPs)
        ├── Amazon Linux 2023
        ├── Docker + Nginx + Jenkins + Git + ECR Access
        └── SSM Session Manager
```

## 📋 Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **Appropriate AWS permissions** for creating VPC, EC2, IAM, Lambda resources

## 🚀 Quick Start

### Step 1: Clone and Configure

```bash
cd aws-iac-terraform
```

### Step 2: Update Configuration

Edit `terraform.tfvars` with your specific values:

```bash
vim terraform.tfvars
```

Key variables to update:
- `aws_region` - Your preferred AWS region
- `project_name` - Name for your project resources
- `allowed_cidr_blocks` - IP ranges allowed to access load balancer
- `instance_type` - EC2 instance size

### Step 3: Deploy Infrastructure

Follow these commands in order:

```bash
terraform init
terraform plan
terraform apply
```

### Step 4: Post-Deployment Setup

#### For Fresh Deployments:
- Git and Jenkins are automatically installed
- Access Jenkins at: `http://[load-balancer-dns]:8080`

#### For Existing Deployments:
If updating an existing deployment, manually install Git and Jenkins:
```bash
# SSH into instance
aws ssm start-session --target $(terraform output -raw instance_ids | jq -r '.[0]')

# Run manual installation (see Manual Installation section below)
```

## 📝 Terraform Commands with Sample Outputs

### 1. Initialize Terraform

```bash
terraform init
```

**Sample Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Finding hashicorp/archive versions matching "~> 2.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)
- Installing hashicorp/archive v2.7.1...
- Installed hashicorp/archive v2.7.1 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.
```

### 2. Validate Configuration

```bash
terraform validate
```

**Sample Output:**
```
Success! The configuration is valid.
```

### 3. Format Code

```bash
terraform fmt
```

**Sample Output:**
```
backup.tf
ec2.tf
load_balancer.tf
terraform.tfvars
variables.tf
```

### 4. Plan Infrastructure

```bash
terraform plan
```

**Sample Output:**
```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dlm_lifecycle_policy.ami_backup_policy will be created
  + resource "aws_dlm_lifecycle_policy" "ami_backup_policy" {
      + arn              = (known after apply)
      + description      = "AMI backup lifecycle policy for my-aws-infrastructure-dev"
      + execution_role_arn = (known after apply)
      + id               = (known after apply)
      + state            = "ENABLED"
      + tags             = {
          + "CostCenter"  = "Engineering"
          + "Environment" = "dev"
          + "Project"     = "my-aws-infrastructure"
          + "Terraform"   = "true"
        }
      + tags_all         = {
          + "CostCenter"  = "Engineering"
          + "Environment" = "dev"
          + "Project"     = "my-aws-infrastructure"
          + "Terraform"   = "true"
        }

      + policy_details {
          + resource_types = [
              + "INSTANCE",
            ]
          + target_tags    = {
              + "Environment" = "dev"
              + "Project"     = "my-aws-infrastructure"
            }

          + schedule {
              + copy_tags = true
              + name      = "Daily AMI backup"
              + tags_to_add = {
                  + "BackupType"      = "AMI"
                  + "CostCenter"      = "Engineering"
                  + "Environment"     = "dev"
                  + "Project"         = "my-aws-infrastructure"
                  + "SnapshotCreator" = "DLM-AMI"
                  + "Terraform"       = "true"
                }

              + create_rule {
                  + interval      = 24
                  + interval_unit = "HOURS"
                  + times         = [
                      + "02:00",
                    ]
                }

              + retain_rule {
                  + count = 7
                }
            }
        }
    }

  # aws_eip.nat will be created
  + resource "aws_eip" "nat" {
      + allocation_id        = (known after apply)
      + arn                  = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = "vpc"
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + ptr_record           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags                 = {
          + "CostCenter"  = "Engineering"
          + "Environment" = "dev"
          + "Name"        = "my-aws-infrastructure-dev-nat-eip"
          + "Owner"       = "DevOps Team"
          + "Project"     = "my-aws-infrastructure"
          + "Terraform"   = "true"
        }
      + tags_all             = {
          + "CostCenter"  = "Engineering"
          + "Environment" = "dev"
          + "Name"        = "my-aws-infrastructure-dev-nat-eip"
          + "Owner"       = "DevOps Team"
          + "Project"     = "my-aws-infrastructure"
          + "Terraform"   = "true"
        }
    }

  # ... (additional resources)

Plan: 33 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + alb_security_group_id       = (known after apply)
  + ami_backup_policy_id        = (known after apply)
  + application_url_http        = (known after apply)
  + application_url_https       = (known after apply)
  + ebs_snapshot_policy_id      = (known after apply)
  + ec2_instance_profile_name   = "my-aws-infrastructure-dev-ec2-profile"
  + ec2_role_arn                = (known after apply)
  + ec2_security_group_id       = (known after apply)
  + instance_availability_zones = [
      + (known after apply),
    ]
  + instance_ids                = [
      + (known after apply),
    ]
  + instance_private_ips        = [
      + (known after apply),
    ]
  + internet_gateway_id         = (known after apply)
  + load_balancer_arn           = (known after apply)
  + load_balancer_dns_name      = (known after apply)
  + load_balancer_zone_id       = (known after apply)
  + nat_gateway_id              = (known after apply)
  + private_subnet_ids          = [
      + (known after apply),
      + (known after apply),
    ]
  + public_subnet_ids           = [
      + (known after apply),
      + (known after apply),
    ]
  + ssm_session_manager_url     = "https://us-west-2.console.aws.amazon.com/systems-manager/session-manager/start-session"
  + vpc_cidr_block              = "10.0.0.0/24"
  + vpc_id                      = (known after apply)
```

### 5. Apply Infrastructure

```bash
terraform apply
```

**Sample Output:**
```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dlm_lifecycle_policy.ami_backup_policy will be created
  + resource "aws_dlm_lifecycle_policy" "ami_backup_policy" {
      + arn              = (known after apply)
      + description      = "AMI backup lifecycle policy for my-aws-infrastructure-dev"
      + execution_role_arn = (known after apply)
      + id               = (known after apply)
      + state            = "ENABLED"
      + tags             = {
          + "CostCenter"  = "Engineering"
          + "Environment" = "dev"
          + "Project"     = "my-aws-infrastructure"
          + "Terraform"   = "true"
        }

      # ... (additional resources)

Plan: 33 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.main: Creating...
aws_iam_role.ec2_role: Creating...
aws_iam_role.dlm_lifecycle_role: Creating...
aws_vpc.main: Creation complete after 2s [id=vpc-0cf8f8ea8456fc378]
aws_internet_gateway.main: Creating...
aws_subnet.private[1]: Creating...
aws_subnet.private[0]: Creating...
aws_subnet.public[0]: Creating...
aws_subnet.public[1]: Creating...
aws_security_group.alb: Creating...
aws_security_group.ec2: Creating...
aws_route_table.public: Creating...
aws_iam_role.ec2_role: Creation complete after 2s [id=my-aws-infrastructure-dev-ec2-role]
aws_iam_role_policy_attachment.ssm_managed_instance_core: Creating...
aws_iam_role_policy_attachment.cloudwatch_agent: Creating...
aws_iam_instance_profile.ec2_profile: Creating...
aws_internet_gateway.main: Creation complete after 1s [id=igw-0a8be4683586fc3e3]
aws_eip.nat: Creating...
aws_subnet.private[1]: Creation complete after 1s [id=subnet-02c0db729e091510b]
aws_subnet.private[0]: Creation complete after 1s [id=subnet-0b73945353afabaf0]
aws_subnet.public[0]: Creation complete after 1s [id=subnet-04bb1a89bd52cd09c]
aws_subnet.public[1]: Creation complete after 1s [id=subnet-07427a6bfaf17471b]
aws_route_table.public: Creation complete after 1s [id=rtb-0f5889071a802c45a]
aws_route_table_association.public[0]: Creating...
aws_route_table_association.public[1]: Creating...
aws_eip.nat: Creation complete after 1s [id=eipalloc-0cf6e3be0ac02d6a1]
aws_nat_gateway.main: Creating...
aws_security_group.alb: Creation complete after 2s [id=sg-01cd3921563b7dbb1]
aws_lb_target_group.http: Creating...
aws_lb_target_group.https: Creating...
aws_lb.main: Creating...
aws_security_group.ec2: Creation complete after 2s [id=sg-01f5e6db793c9e33f]
aws_route_table_association.public[0]: Creation complete after 1s [id=rtbassoc-0b1640140f6f2d9cb]
aws_route_table_association.public[1]: Creation complete after 1s [id=rtbassoc-0a1d10d5276decf75]
aws_lb_target_group.http: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructur-dev-http-tg/d5ef7c4b4e7c0670]
aws_lb_target_group.https: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructu-dev-https-tg/4e541ac1559d0735]
aws_iam_role_policy_attachment.ssm_managed_instance_core: Creation complete after 2s [id=my-aws-infrastructure-dev-ec2-role-20251216110603477200000001]
aws_iam_role_policy_attachment.cloudwatch_agent: Creation complete after 2s [id=my-aws-infrastructure-dev-ec2-role-20251216110603833500000002]
aws_iam_instance_profile.ec2_profile: Creation complete after 2s [id=my-aws-infrastructure-dev-ec2-profile]
aws_instance.main[0]: Creating...
aws_nat_gateway.main: Still creating... [00m10s elapsed]
aws_lb.main: Still creating... [00m10s elapsed]
aws_instance.main[0]: Still creating... [00m10s elapsed]
aws_nat_gateway.main: Creation complete after 1m27s [id=nat-076803094ee35aea3]
aws_route_table.private: Creating...
aws_route_table.private: Creation complete after 1s [id=rtb-01decacd9c74a1fe0]
aws_route_table_association.private[0]: Creating...
aws_route_table_association.private[1]: Creating...
aws_route_table_association.private[0]: Creation complete after 1s [id=rtbassoc-017641ab1f9ed5898]
aws_route_table_association.private[1]: Creation complete after 1s [id=rtbassoc-051a9087af9f065e6]
aws_lb.main: Still creating... [00m20s elapsed]
aws_instance.main[0]: Still creating... [00m20s elapsed]
aws_lb.main: Still creating... [00m30s elapsed]
aws_instance.main[0]: Still creating... [00m30s elapsed]
aws_lb.main: Still creating... [00m40s elapsed]
aws_instance.main[0]: Still creating... [00m40s elapsed]
aws_instance.main[0]: Still creating... [00m50s elapsed]
aws_instance.main[0]: Creation complete after 52s [id=i-0cc6c86c24b0ace66]
aws_lb_target_group_attachment.https[0]: Creating...
aws_lb_target_group_attachment.http[0]: Creating...
aws_lb_target_group_attachment.https[0]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructu-dev-https-tg/4e541ac1559d0735-20251216111600018400000002]
aws_lb_target_group_attachment.http[0]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructur-dev-http-tg/d5ef7c4b4e7c0670-20251216111600021400000003]
aws_lb.main: Creation complete after 3m7s [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47]
aws_lb_listener.http: Creating...
aws_lb_listener.https: Creating...
aws_lb_listener.https: Creation complete after 3s [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:listener/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47/4ad341ba31871d33]
aws_lb_listener.http: Creation complete after 3s [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:listener/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47/1653ecc9adfc4824]

Apply complete! Resources: 33 added, 0 changed, 0 destroyed.

Outputs:

alb_security_group_id = "sg-01cd3921563b7dbb1"
ami_backup_policy_id = "policy-0792030be527ff13d"
application_url_http = "http://my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com"
application_url_https = "https://my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com"
ebs_snapshot_policy_id = "policy-00d3d64a57af9b554"
ec2_instance_profile_name = "my-aws-infrastructure-dev-ec2-profile"
ec2_role_arn = "arn:aws:iam::588738614863:role/my-aws-infrastructure-dev-ec2-role"
ec2_security_group_id = "sg-01f5e6db793c9e33f"
instance_availability_zones = [
  "us-west-2a",
]
instance_ids = [
  "i-0cc6c86c24b0ace66",
]
instance_private_ips = [
  "10.0.0.167",
]
internet_gateway_id = "igw-0a8be4683586fc3e3"
load_balancer_arn = "arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47"
load_balancer_dns_name = "my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com"
load_balancer_zone_id = "Z1H1FL5HABSF5"
nat_gateway_id = "nat-076803094ee35aea3"
private_subnet_ids = [
  "subnet-0b73945353afabaf0",
  "subnet-02c0db729e091510b",
]
public_subnet_ids = [
  "subnet-04bb1a89bd52cd09c",
  "subnet-07427a6bfaf17471b",
]
ssm_session_manager_url = "https://us-west-2.console.aws.amazon.com/systems-manager/session-manager/start-session"
vpc_cidr_block = "10.0.0.0/24"
vpc_id = "vpc-0cf8f8ea8456fc378"
```

### 6. Show Current State

```bash
terraform show
```

**Sample Output:**
```
# aws_dlm_lifecycle_policy.ami_backup_policy:
resource "aws_dlm_lifecycle_policy" "ami_backup_policy" {
    arn              = "arn:aws:dlm:us-west-2:588738614863:policy/policy-0792030be527ff13d"
    description      = "AMI backup lifecycle policy for my-aws-infrastructure-dev"
    execution_role_arn = "arn:aws:iam::588738614863:role/my-aws-infrastructure-dev-dlm-lifecycle-role"
    id               = "policy-0792030be527ff13d"
    state            = "ENABLED"
    tags             = {
        "CostCenter"  = "Engineering"
        "Environment" = "dev"
        "Project"     = "my-aws-infrastructure"
        "Terraform"   = "true"
    }
    tags_all         = {
        "CostCenter"  = "Engineering"
        "Environment" = "dev"
        "Project"     = "my-aws-infrastructure"
        "Terraform"   = "true"
    }

    policy_details {
        resource_types = [
            "INSTANCE",
        ]
        target_tags    = {
            "Environment" = "dev"
            "Project"     = "my-aws-infrastructure"
        }

        schedule {
            copy_tags = true
            name      = "Daily AMI backup"
            tags_to_add = {
                "BackupType"      = "AMI"
                "CostCenter"      = "Engineering"
                "Environment"     = "dev"
                "Project"         = "my-aws-infrastructure"
                "SnapshotCreator" = "DLM-AMI"
                "Terraform"       = "true"
            }

            create_rule {
                interval      = 24
                interval_unit = "HOURS"
                times         = [
                    "02:00",
                ]
            }

            retain_rule {
                count = 7
            }
        }
    }
}

# ... (additional resources)
```

### 7. List Resources

```bash
terraform state list
```

**Sample Output:**
```
aws_dlm_lifecycle_policy.ami_backup_policy
aws_dlm_lifecycle_policy.ebs_snapshot_policy
aws_eip.nat
aws_iam_instance_profile.ec2_profile
aws_iam_role.dlm_lifecycle_role
aws_iam_role.ec2_role
aws_iam_role_policy.dlm_lifecycle_policy
aws_iam_role_policy_attachment.cloudwatch_agent
aws_iam_role_policy_attachment.ssm_managed_instance_core
aws_instance.main[0]
aws_internet_gateway.main
aws_lb.main
aws_lb_listener.http
aws_lb_listener.https
aws_lb_target_group.http
aws_lb_target_group.https
aws_lb_target_group_attachment.http[0]
aws_lb_target_group_attachment.https[0]
aws_nat_gateway.main
aws_route_table.private
aws_route_table.public
aws_route_table_association.private[0]
aws_route_table_association.private[1]
aws_route_table_association.public[0]
aws_route_table_association.public[1]
aws_security_group.alb
aws_security_group.ec2
aws_subnet.private[0]
aws_subnet.private[1]
aws_subnet.public[0]
aws_subnet.public[1]
aws_vpc.main
data.aws_ami.amazon_linux
data.aws_caller_identity.current
```

### 8. View Outputs

```bash
terraform output
```

**Sample Output:**
```
alb_security_group_id = "sg-01cd3921563b7dbb1"
ami_backup_policy_id = "policy-0792030be527ff13d"
application_url_http = "http://my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com"
application_url_https = "https://my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com"
ebs_snapshot_policy_id = "policy-00d3d64a57af9b554"
ec2_instance_profile_name = "my-aws-infrastructure-dev-ec2-profile"
ec2_role_arn = "arn:aws:iam::588738614863:role/my-aws-infrastructure-dev-ec2-role"
ec2_security_group_id = "sg-01f5e6db793c9e33f"
instance_availability_zones = tolist([
  "us-west-2a",
])
instance_ids = tolist([
  "i-0cc6c86c24b0ace66",
])
instance_private_ips = tolist([
  "10.0.0.167",
])
internet_gateway_id = "igw-0a8be4683586fc3e3"
load_balancer_arn = "arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47"
load_balancer_dns_name = "my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com"
load_balancer_zone_id = "Z1H1FL5HABSF5"
nat_gateway_id = "nat-076803094ee35aea3"
private_subnet_ids = tolist([
  "subnet-0b73945353afabaf0",
  "subnet-02c0db729e091510b",
])
public_subnet_ids = tolist([
  "subnet-04bb1a89bd52cd09c",
  "subnet-07427a6bfaf17471b",
])
ssm_session_manager_url = "https://us-west-2.console.aws.amazon.com/systems-manager/session-manager/start-session"
vpc_cidr_block = "10.0.0.0/24"
vpc_id = "vpc-0cf8f8ea8456fc378"
```

### 9. Get Specific Output

```bash
terraform output application_url_http
```

**Sample Output:**
```
"http://my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com"
```

### 10. Refresh State

```bash
terraform refresh
```

**Sample Output:**
```
data.aws_caller_identity.current: Reading...
data.aws_ami.amazon_linux: Reading...
aws_vpc.main: Refreshing state... [id=vpc-0cf8f8ea8456fc378]
aws_iam_role.dlm_lifecycle_role: Refreshing state... [id=my-aws-infrastructure-dev-dlm-lifecycle-role]
aws_iam_role.ec2_role: Refreshing state... [id=my-aws-infrastructure-dev-ec2-role]
data.aws_caller_identity.current: Read complete after 1s [id=588738614863]
data.aws_ami.amazon_linux: Read complete after 2s [id=ami-0a652ed1e30c792a2]
aws_iam_role_policy_attachment.cloudwatch_agent: Refreshing state... [id=my-aws-infrastructure-dev-ec2-role-20251216110603833500000002]
aws_iam_role_policy_attachment.ssm_managed_instance_core: Refreshing state... [id=my-aws-infrastructure-dev-ec2-role-20251216110603477200000001]
aws_iam_instance_profile.ec2_profile: Refreshing state... [id=my-aws-infrastructure-dev-ec2-profile]
aws_iam_role_policy.dlm_lifecycle_policy: Refreshing state... [id=my-aws-infrastructure-dev-dlm-lifecycle-role:my-aws-infrastructure-dev-dlm-lifecycle-policy]
aws_dlm_lifecycle_policy.ebs_snapshot_policy: Refreshing state... [id=policy-00d3d64a57af9b554]
aws_dlm_lifecycle_policy.ami_backup_policy: Refreshing state... [id=policy-0792030be527ff13d]
aws_internet_gateway.main: Refreshing state... [id=igw-0a8be4683586fc3e3]
aws_subnet.private[1]: Refreshing state... [id=subnet-02c0db729e091510b]
aws_subnet.public[0]: Refreshing state... [id=subnet-04bb1a89bd52cd09c]
aws_subnet.public[1]: Refreshing state... [id=subnet-07427a6bfaf17471b]
aws_subnet.private[0]: Refreshing state... [id=subnet-0b73945353afabaf0]
aws_lb_target_group.https: Refreshing state... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructu-dev-https-tg/4e541ac1559d0735]
aws_lb_target_group.http: Refreshing state... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructur-dev-http-tg/d5ef7c4b4e7c0670]
aws_security_group.alb: Refreshing state... [id=sg-01cd3921563b7dbb1]
aws_route_table.public: Refreshing state... [id=rtb-0f5889071a802c45a]
aws_eip.nat: Refreshing state... [id=eipalloc-0cf6e3be0ac02d6a1]
aws_security_group.ec2: Refreshing state... [id=sg-01f5e6db793c9e33f]
aws_route_table_association.public[0]: Refreshing state... [id=rtbassoc-0b1640140f6f2d9cb]
aws_route_table_association.public[1]: Refreshing state... [id=rtbassoc-0a1d10d5276decf75]
aws_lb.main: Refreshing state... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47]
aws_instance.main[0]: Refreshing state... [id=i-0cc6c86c24b0ace66]
aws_nat_gateway.main: Refreshing state... [id=nat-076803094ee35aea3]
aws_route_table.private: Refreshing state... [id=rtb-01decacd9c74a1fe0]
aws_route_table_association.private[0]: Refreshing state... [id=rtbassoc-017641ab1f9ed5898]
aws_route_table_association.private[1]: Refreshing state... [id=rtbassoc-051a9087af9f065e6]
aws_lb_listener.https: Refreshing state... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:listener/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47/4ad341ba31871d33]
aws_lb_listener.http: Refreshing state... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:listener/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47/1653ecc9adfc4824]
aws_lb_target_group_attachment.https[0]: Refreshing state... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructu-dev-https-tg/4e541ac1559d0735-20251216111600018400000002]
aws_lb_target_group_attachment.http[0]: Refreshing state... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructur-dev-http-tg/d5ef7c4b4e7c0670-20251216111600021400000003]
```

### 11. Destroy Infrastructure (When Done)

```bash
terraform destroy
```

**Sample Output:**
```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_dlm_lifecycle_policy.ami_backup_policy will be destroyed
  - resource "aws_dlm_lifecycle_policy" "ami_backup_policy" {
      - arn              = "arn:aws:dlm:us-west-2:588738614863:policy/policy-0792030be527ff13d" -> null
      - description      = "AMI backup lifecycle policy for my-aws-infrastructure-dev" -> null
      - execution_role_arn = "arn:aws:iam::588738614863:role/my-aws-infrastructure-dev-dlm-lifecycle-role" -> null
      - id               = "policy-0792030be527ff13d" -> null
      - state            = "ENABLED" -> null
      - tags             = {
          - "CostCenter"  = "Engineering"
          - "Environment" = "dev"
          - "Project"     = "my-aws-infrastructure"
          - "Terraform"   = "true"
        } -> null
      - tags_all         = {
          - "CostCenter"  = "Engineering"
          - "Environment" = "dev"
          - "Project"     = "my-aws-infrastructure"
          - "Terraform"   = "true"
        } -> null

      # ... (additional resources to be destroyed)

Plan: 0 to add, 0 to change, 33 to destroy.

Changes to Outputs:
  - alb_security_group_id       = "sg-01cd3921563b7dbb1" -> null
  - ami_backup_policy_id        = "policy-0792030be527ff13d" -> null
  - application_url_http        = "http://my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com" -> null
  - application_url_https       = "https://my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com" -> null
  - ebs_snapshot_policy_id      = "policy-00d3d64a57af9b554" -> null
  - ec2_instance_profile_name   = "my-aws-infrastructure-dev-ec2-profile" -> null
  - ec2_role_arn                = "arn:aws:iam::588738614863:role/my-aws-infrastructure-dev-ec2-role" -> null
  - ec2_security_group_id       = "sg-01f5e6db793c9e33f" -> null
  - instance_availability_zones = [
      - "us-west-2a",
    ] -> null
  - instance_ids                = [
      - "i-0cc6c86c24b0ace66",
    ] -> null
  - instance_private_ips        = [
      - "10.0.0.167",
    ] -> null
  - internet_gateway_id         = "igw-0a8be4683586fc3e3" -> null
  - load_balancer_arn           = "arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47" -> null
  - load_balancer_dns_name      = "my-aws-infrastructure-dev-alb-2067205643.us-west-2.elb.amazonaws.com" -> null
  - load_balancer_zone_id       = "Z1H1FL5HABSF5" -> null
  - nat_gateway_id              = "nat-076803094ee35aea3" -> null
  - private_subnet_ids          = [
      - "subnet-0b73945353afabaf0",
      - "subnet-02c0db729e091510b",
    ] -> null
  - public_subnet_ids           = [
      - "subnet-04bb1a89bd52cd09c",
      - "subnet-07427a6bfaf17471b",
    ] -> null
  - ssm_session_manager_url     = "https://us-west-2.console.aws.amazon.com/systems-manager/session-manager/start-session" -> null
  - vpc_cidr_block              = "10.0.0.0/24" -> null
  - vpc_id                      = "vpc-0cf8f8ea8456fc378" -> null

Do you really want to destroy all resources?
  Terraform will destroy all the resources used by this configuration.
  This action cannot be undone.

  Enter a value: yes

aws_lb_target_group_attachment.https[0]: Destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructu-dev-https-tg/4e541ac1559d0735-20251216111600018400000002]
aws_lb_target_group_attachment.http[0]: Destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructur-dev-http-tg/d5ef7c4b4e7c0670-20251216111600021400000003]
aws_lb_listener.https: Destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:listener/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47/4ad341ba31871d33]
aws_lb_listener.http: Destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:listener/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47/1653ecc9adfc4824]
aws_dlm_lifecycle_policy.ami_backup_policy: Destroying... [id=policy-0792030be527ff13d]
aws_dlm_lifecycle_policy.ebs_snapshot_policy: Destroying... [id=policy-00d3d64a57af9b554]
aws_lb_target_group_attachment.https[0]: Destruction complete after 1s
aws_lb_target_group_attachment.http[0]: Destruction complete after 1s
aws_lb_listener.https: Destruction complete after 1s
aws_lb_listener.http: Destruction complete after 1s
aws_lb.main: Destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47]
aws_dlm_lifecycle_policy.ami_backup_policy: Destruction complete after 2s
aws_dlm_lifecycle_policy.ebs_snapshot_policy: Destruction complete after 2s
aws_instance.main[0]: Destroying... [id=i-0cc6c86c24b0ace66]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 00m10s elapsed]
aws_instance.main[0]: Still destroying... [id=i-0cc6c86c24b0ace66, 00m10s elapsed]
aws_instance.main[0]: Still destroying... [id=i-0cc6c86c24b0ace66, 00m20s elapsed]
aws_instance.main[0]: Still destroying... [id=i-0cc6c86c24b0ace66, 00m30s elapsed]
aws_instance.main[0]: Destruction complete after 32s
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 00m20s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 00m30s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 00m40s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 00m50s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 01m00s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 01m10s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 01m20s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 01m30s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 01m40s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 01m50s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 02m00s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 02m10s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 02m20s elapsed]
aws_lb.main: Still destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:loadbalancer/app/my-aws-infrastructure-dev-alb/fbd680a8a7785f47, 02m30s elapsed]
aws_lb.main: Destruction complete after 2m33s
aws_lb_target_group.https: Destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructu-dev-https-tg/4e541ac1559d0735]
aws_lb_target_group.http: Destroying... [id=arn:aws:elasticloadbalancing:us-west-2:588738614863:targetgroup/my-aws-infrastructur-dev-http-tg/d5ef7c4b4e7c0670]
aws_security_group.alb: Destroying... [id=sg-01cd3921563b7dbb1]
aws_lb_target_group.https: Destruction complete after 1s
aws_lb_target_group.http: Destruction complete after 1s
aws_security_group.alb: Destruction complete after 1s
aws_route_table_association.private[0]: Destroying... [id=rtbassoc-017641ab1f9ed5898]
aws_route_table_association.private[1]: Destroying... [id=rtbassoc-051a9087af9f065e6]
aws_security_group.ec2: Destroying... [id=sg-01f5e6db793c9e33f]
aws_iam_instance_profile.ec2_profile: Destroying... [id=my-aws-infrastructure-dev-ec2-profile]
aws_route_table_association.private[0]: Destruction complete after 1s
aws_route_table_association.private[1]: Destruction complete after 1s
aws_route_table.private: Destroying... [id=rtb-01decacd9c74a1fe0]
aws_security_group.ec2: Destruction complete after 1s
aws_iam_instance_profile.ec2_profile: Destruction complete after 1s
aws_route_table.private: Destruction complete after 1s
aws_nat_gateway.main: Destroying... [id=nat-076803094ee35aea3]
aws_iam_role_policy_attachment.cloudwatch_agent: Destroying... [id=my-aws-infrastructure-dev-ec2-role-20251216110603833500000002]
aws_iam_role_policy_attachment.ssm_managed_instance_core: Destroying... [id=my-aws-infrastructure-dev-ec2-role-20251216110603477200000001]
aws_iam_role_policy_attachment.cloudwatch_agent: Destruction complete after 1s
aws_iam_role_policy_attachment.ssm_managed_instance_core: Destruction complete after 1s
aws_iam_role.ec2_role: Destroying... [id=my-aws-infrastructure-dev-ec2-role]
aws_iam_role.ec2_role: Destruction complete after 1s
aws_nat_gateway.main: Still destroying... [id=nat-076803094ee35aea3, 00m10s elapsed]
aws_nat_gateway.main: Still destroying... [id=nat-076803094ee35aea3, 00m20s elapsed]
aws_nat_gateway.main: Still destroying... [id=nat-076803094ee35aea3, 00m30s elapsed]
aws_nat_gateway.main: Still destroying... [id=nat-076803094ee35aea3, 00m40s elapsed]
aws_nat_gateway.main: Destruction complete after 42s
aws_eip.nat: Destroying... [id=eipalloc-0cf6e3be0ac02d6a1]
aws_route_table_association.public[0]: Destroying... [id=rtbassoc-0b1640140f6f2d9cb]
aws_route_table_association.public[1]: Destroying... [id=rtbassoc-0a1d10d5276decf75]
aws_subnet.private[0]: Destroying... [id=subnet-0b73945353afabaf0]
aws_subnet.private[1]: Destroying... [id=subnet-02c0db729e091510b]
aws_subnet.public[0]: Destroying... [id=subnet-04bb1a89bd52cd09c]
aws_subnet.public[1]: Destroying... [id=subnet-07427a6bfaf17471b]
aws_eip.nat: Destruction complete after 1s
aws_route_table_association.public[0]: Destruction complete after 1s
aws_route_table_association.public[1]: Destruction complete after 1s
aws_subnet.private[0]: Destruction complete after 1s
aws_subnet.private[1]: Destruction complete after 1s
aws_subnet.public[0]: Destruction complete after 1s
aws_subnet.public[1]: Destruction complete after 1s
aws_route_table.public: Destroying... [id=rtb-0f5889071a802c45a]
aws_route_table.public: Destruction complete after 1s
aws_internet_gateway.main: Destroying... [id=igw-0a8be4683586fc3e3]
aws_internet_gateway.main: Still destroying... [id=igw-0a8be4683586fc3e3, 00m10s elapsed]
aws_internet_gateway.main: Destruction complete after 11s
aws_iam_role_policy.dlm_lifecycle_policy: Destroying... [id=my-aws-infrastructure-dev-dlm-lifecycle-role:my-aws-infrastructure-dev-dlm-lifecycle-policy]
aws_vpc.main: Destroying... [id=vpc-0cf8f8ea8456fc378]
aws_iam_role_policy.dlm_lifecycle_policy: Destruction complete after 1s
aws_iam_role.dlm_lifecycle_role: Destroying... [id=my-aws-infrastructure-dev-dlm-lifecycle-role]
aws_vpc.main: Destruction complete after 1s
aws_iam_role.dlm_lifecycle_role: Destruction complete after 1s

Destroy complete! Resources: 33 destroyed.
```

## 🔧 Useful Makefile Commands

You can also use the provided Makefile for common operations:

```bash
# Initialize and validate
make init
make validate
make format

# Plan and apply
make plan
make apply

# Clean up
make destroy
make clean
```

## 🌐 Access Your Application

After successful deployment, access your application using the Load Balancer URLs from the outputs:

### Web Application (Nginx)
```bash
# Get the URL
terraform output application_url_http

# Visit in browser or curl
curl $(terraform output -raw application_url_http)
```

### Jenkins CI/CD Server

#### For New Deployments (Fresh Instances)
Jenkins is automatically installed via user data script.

#### For Existing Instances (Manual Installation Required)
If you're updating an existing deployment, run the manual installation script:

```bash
# SSH into the instance via SSM
aws ssm start-session --target $(terraform output -raw instance_ids | jq -r '.[0]')

# Download and run the manual installation script
curl -o manual-install.sh https://raw.githubusercontent.com/your-repo/aws-iac-terraform/main/manual-install.sh
chmod +x manual-install.sh
sudo ./manual-install.sh
```

#### Jenkins Access and Setup

1. **Get Jenkins URL:**
   ```bash
   terraform output jenkins_url
   # Output: http://[load-balancer-dns]:8080
   ```

2. **Get Initial Admin Password:**
   ```bash
   # Via SSM Session Manager
   aws ssm start-session --target $(terraform output -raw instance_ids | jq -r '.[0]')
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. **Jenkins First-Time Setup:**
   - Open Jenkins URL in browser: `http://[load-balancer-dns]:8080`
   - Enter the initial admin password from step 2
   - Choose "Install suggested plugins"
   - Create your first admin user
   - Configure Jenkins URL (use the load balancer URL)

4. **Jenkins Service Management:**
   ```bash
   # Check Jenkins status
   sudo systemctl status jenkins
   
   # Start/Stop/Restart Jenkins
   sudo systemctl start jenkins
   sudo systemctl stop jenkins
   sudo systemctl restart jenkins
   
   # View Jenkins logs
   sudo journalctl -u jenkins -f
   ```

5. **Jenkins Configuration:**
   - **Jenkins Home:** `/var/lib/jenkins`
   - **Configuration:** `/etc/sysconfig/jenkins`
   - **Logs:** `/var/log/jenkins/jenkins.log`
   - **Port:** 8080 (accessible via Load Balancer)

6. **Recommended Jenkins Plugins:**
   - Git plugin (for source control)
   - Docker plugin (for containerized builds)
   - AWS CLI plugin (for AWS integrations)
   - Pipeline plugin (for CI/CD pipelines)
   - Blue Ocean (modern UI)

#### Troubleshooting Jenkins

```bash
# If Jenkins is not starting, check logs
sudo journalctl -u jenkins --no-pager

# Check if port 8080 is listening
sudo netstat -tlnp | grep 8080

# Restart Jenkins if needed
sudo systemctl restart jenkins

# Check Java installation
java -version

# Verify Jenkins user and permissions
sudo ls -la /var/lib/jenkins
```

## 🔐 Secure Access to EC2 Instances

Access your EC2 instances securely via SSM Session Manager:

```bash
# Get instance ID
INSTANCE_ID=$(terraform output -raw instance_ids | jq -r '.[0]')

# Start SSM session
aws ssm start-session --target $INSTANCE_ID
```

## 📊 Monitoring and Maintenance

### Check Infrastructure Status
```bash
# View all resources
terraform state list

# Check specific resource
terraform state show aws_instance.main[0]

# Refresh state
terraform refresh
```

### Backup Management
```bash
# View DLM policies
aws dlm get-lifecycle-policies

# View AMI backups
aws ec2 describe-images --owners self --filters "Name=tag:SnapshotCreator,Values=DLM-AMI"
```

## 🧹 Cleanup

When you're done with the infrastructure:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources including backups.

## 📁 Project Structure

```
aws-iac-terraform/
├── README.md                    # This file
├── DEPLOYMENT.md               # Detailed deployment guide
├── SETUP_SUMMARY.md            # Setup summary and fixes
├── Makefile                    # Automation commands
├── .gitignore                  # Git ignore rules
├── versions.tf                 # Terraform version constraints
├── variables.tf                # Input variables
├── terraform.tfvars           # Variable values (customize this)
├── main.tf                    # Provider and data sources
├── vpc.tf                     # VPC, subnets, routing
├── security_groups.tf         # Security group rules
├── iam.tf                     # IAM roles and policies

├── ec2.tf                     # EC2 instances
├── load_balancer.tf           # Application Load Balancer
├── backup.tf                  # Backup automation
├── user_data.sh              # Instance initialization script
└── outputs.tf                # Output values
```

## 🎯 Key Features

- ✅ **Secure Architecture** - Private instances, no public IPs
- ✅ **High Availability** - Multi-AZ deployment
- ✅ **Auto Scaling Ready** - Launch template configured
- ✅ **Automated Backups** - Daily AMI and EBS snapshots
- ✅ **Container Ready** - Docker + ECR access configured
- ✅ **Cost Optimized** - Native AWS services, efficient sizing
- ✅ **Production Ready** - Termination protection, monitoring
- ✅ **Best Practices** - AWS Well-Architected Framework compliant

## 🆘 Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure AWS credentials have sufficient permissions
2. **Region Issues**: Update `aws_region` in `terraform.tfvars`
3. **Resource Limits**: Check AWS service quotas in your region
4. **State Lock**: If state is locked, wait or force unlock if necessary

### Getting Help

- Check `terraform plan` output for issues
- Review AWS CloudTrail for API errors
- Use `terraform refresh` to sync state
- Check security group rules and network ACLs

### Manual Installation for Existing Deployments

If you deployed the infrastructure before Git and Jenkins were added to the user data script, you'll need to manually install them:

```bash
# 1. SSH into the instance
aws ssm start-session --target $(terraform output -raw instance_ids | jq -r '.[0]')

# 2. Run the manual installation commands
sudo yum update -y
sudo yum install -y git
sudo yum install -y java-17-amazon-corretto-headless

# 3. Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins

# 4. Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# 5. Get Jenkins password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# 6. Access Jenkins at: http://[load-balancer-dns]:8080
```

### Service Status Check

```bash
# Check all services
sudo systemctl status docker nginx jenkins amazon-ssm-agent

# Check Git installation
git --version

# Check Java installation
java -version

# Check Jenkins initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

**Happy Infrastructure Building!** 🚀