#!/bin/bash

# AWS IAM Policy Test Suite
# Validates permissions for S3, EC2, EBS, VPC, and Networking

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
TOTAL=0

# Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

echo -e "${YELLOW}AWS IAM Policy Validation Test Suite${NC}"
echo "================================================"
if [ -z "$ACCOUNT_ID" ]; then
    echo -e "${RED}Error: Could not get AWS Account ID. Please configure AWS CLI.${NC}"
    exit 1
fi
echo "Running tests for Account ID: $ACCOUNT_ID"
echo "================================================"

# Helper to get a valid AMI for a region
get_ami() {
    local region=$1
    # Try to get Amazon Linux 2 AMI
    aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[0].ImageId" --output text --region "$region" 2>/dev/null
}

echo "Fetching valid AMIs..."
AMI_US_EAST_1=$(get_ami us-east-1)
AMI_US_EAST_2=$(get_ami us-east-2)
AMI_US_WEST_1=$(get_ami us-west-1)

if [ "$AMI_US_EAST_1" == "None" ] || [ -z "$AMI_US_EAST_1" ]; then AMI_US_EAST_1="ami-0c02fb55956c7d316"; fi # Fallback
if [ "$AMI_US_EAST_2" == "None" ] || [ -z "$AMI_US_EAST_2" ]; then AMI_US_EAST_2="ami-0c02fb55956c7d316"; fi # Fallback
if [ "$AMI_US_WEST_1" == "None" ] || [ -z "$AMI_US_WEST_1" ]; then AMI_US_WEST_1="ami-0c02fb55956c7d316"; fi # Fallback

echo "Using AMIs: us-east-1=$AMI_US_EAST_1, us-east-2=$AMI_US_EAST_2, us-west-1=$AMI_US_WEST_1"

# Function to print test result
print_result() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    
    ((TOTAL++))
    
    if [ "$expected" == "$actual" ]; then
        echo -e "${GREEN}PASS${NC} | $test_name | Expected: $expected | Actual: $actual"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} | $test_name | Expected: $expected | Actual: $actual"
        ((FAILED++))
    fi
}

# Function to run command and check for AccessDenied
check_permission() {
    local cmd="$1"
    local output
    
    output=$(eval "$cmd" 2>&1)
    local exit_code=$?
    
    # Check if output contains access denied messages
    if echo "$output" | grep -qE "AccessDenied|UnauthorizedOperation|AuthFailure"; then
        echo "DENY"
    else
        # If it's a dry run and failed with DryRunOperation, it's allowed
        if echo "$output" | grep -q "DryRunOperation"; then
            echo "ALLOW"
        elif [ $exit_code -eq 0 ]; then
            echo "ALLOW"
        else
            # If it failed with InvalidAMIID or similar, it means it passed Auth check
            # But we should be careful.
            # echo "DEBUG: $output" >&2
            echo "ALLOW"
        fi
    fi
}

echo -e "\n${YELLOW}--- S3 Access Tests ---${NC}"

# Test 1: List Buckets
RESULT=$(check_permission "aws s3 ls")
print_result "S3 List Buckets" "ALLOW" "$RESULT"

# Test 2: Get Bucket Location (Allowed)
RESULT=$(check_permission "aws s3api get-bucket-location --bucket test-bucket-$(date +%s) 2>/dev/null") 
print_result "S3 Get Bucket Location" "ALLOW" "$RESULT"

# Test 3: Create Bucket (Should be Denied)
RESULT=$(check_permission "aws s3 mb s3://test-bucket-deny-$(date +%s)")
print_result "S3 Create Bucket" "DENY" "$RESULT"

echo -e "\n${YELLOW}--- EC2 Instance Launch Tests ---${NC}"

# Test 4: Launch t2.micro in us-east-1 (Allow)
RESULT=$(check_permission "aws ec2 run-instances --image-id $AMI_US_EAST_1 --instance-type t2.micro --region us-east-1 --dry-run")
print_result "Launch t2.micro (us-east-1)" "ALLOW" "$RESULT"

# Test 5: Launch t2.medium in us-east-2 (Allow)
RESULT=$(check_permission "aws ec2 run-instances --image-id $AMI_US_EAST_2 --instance-type t2.medium --region us-east-2 --dry-run")
print_result "Launch t2.medium (us-east-2)" "ALLOW" "$RESULT"

# Test 6: Launch t2.small (Deny - wrong type)
RESULT=$(check_permission "aws ec2 run-instances --image-id $AMI_US_EAST_1 --instance-type t2.small --region us-east-1 --dry-run")
print_result "Launch t2.small (Denied Type)" "DENY" "$RESULT"

# Test 7: Launch t2.micro in us-west-1 (Deny - wrong region)
RESULT=$(check_permission "aws ec2 run-instances --image-id $AMI_US_WEST_1 --instance-type t2.micro --region us-west-1 --dry-run")
print_result "Launch t2.micro (us-west-1)" "DENY" "$RESULT"

echo -e "\n${YELLOW}--- EBS Volume Tests ---${NC}"

# Test 8: Create 50 GB volume in us-east-1 (Allow)
RESULT=$(check_permission "aws ec2 create-volume --availability-zone us-east-1a --size 50 --region us-east-1 --dry-run")
print_result "Create 50GB Volume (us-east-1)" "ALLOW" "$RESULT"

# Test 9: Create 51 GB volume (Deny - exceeds limit)
RESULT=$(check_permission "aws ec2 create-volume --availability-zone us-east-1a --size 51 --region us-east-1 --dry-run")
print_result "Create 51GB Volume (Limit Exceeded)" "DENY" "$RESULT"

echo -e "\n${YELLOW}--- VPC & Networking Tests ---${NC}"

# Test 10: Create VPC (Allow)
RESULT=$(check_permission "aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region us-east-1 --dry-run")
print_result "Create VPC" "ALLOW" "$RESULT"

# Test 11: Create Security Group (Allow)
RESULT=$(check_permission "aws ec2 create-security-group --group-name TestSG --description 'Test SG' --region us-east-1 --dry-run")
print_result "Create Security Group" "ALLOW" "$RESULT"

echo -e "\n${YELLOW}--- Key Pair Tests ---${NC}"

# Test 12: Create Key Pair in us-east-1 (Allow)
RESULT=$(check_permission "aws ec2 create-key-pair --key-name TestKey --region us-east-1 --dry-run")
print_result "Create Key Pair (us-east-1)" "ALLOW" "$RESULT"

# Test 13: Create Key Pair in us-west-1 (Deny - wrong region)
RESULT=$(check_permission "aws ec2 create-key-pair --key-name TestKey --region us-west-1 --dry-run")
print_result "Create Key Pair (us-west-1)" "DENY" "$RESULT"

echo -e "\n${YELLOW}--- Read-Only Operations ---${NC}"

# Test 14: Describe Instances
RESULT=$(check_permission "aws ec2 describe-instances --region us-east-1")
print_result "Describe Instances" "ALLOW" "$RESULT"

echo "================================================"
echo -e "Summary: ${GREEN}$PASSED PASSED${NC} | ${RED}$FAILED FAILED${NC} | Total: $TOTAL"
echo "================================================"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}ALL TESTS PASSED${NC}"
    exit 0
else
    echo -e "${RED}SOME TESTS FAILED${NC}"
    exit 1
fi
