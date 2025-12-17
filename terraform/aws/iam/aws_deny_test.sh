#!/bin/bash

# AWS Deny Policy Test
# Attempts to perform forbidden actions and verifies they are DENIED.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}AWS Deny Policy Validation${NC}"
echo "This script attempts actions that SHOULD FAIL."
echo "================================================"

# Helper to get AMI
get_ami() {
    aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[0].ImageId" --output text --region "$1" 2>/dev/null
}

echo "Fetching AMIs..."
AMI_US_EAST_1=$(get_ami us-east-1)
if [ -z "$AMI_US_EAST_1" ] || [ "$AMI_US_EAST_1" == "None" ]; then AMI_US_EAST_1="ami-0c02fb55956c7d316"; fi
AMI_US_WEST_1=$(get_ami us-west-1)
if [ -z "$AMI_US_WEST_1" ] || [ "$AMI_US_WEST_1" == "None" ]; then AMI_US_WEST_1="ami-0c02fb55956c7d316"; fi # Fallback

# Function to run test and expect failure
expect_deny() {
    local test_name="$1"
    local cmd="$2"
    
    echo -n "Testing: $test_name... "
    
    # Run command and capture output
    OUTPUT=$(eval "$cmd" 2>&1)
    EXIT_CODE=$?
    
    # Check if it failed with AccessDenied
    if echo "$OUTPUT" | grep -qE "AccessDenied|UnauthorizedOperation|AuthFailure"; then
        echo -e "${GREEN}PASS${NC} (Correctly Denied)"
    elif echo "$OUTPUT" | grep -q "DryRunOperation"; then
        echo -e "${RED}FAIL${NC} (Action was ALLOWED but should be DENIED)"
    elif [ $EXIT_CODE -eq 0 ]; then
        echo -e "${RED}FAIL${NC} (Action was ALLOWED but should be DENIED)"
        # Try to cleanup if it actually succeeded!
        echo "WARNING: Resource might have been created! Check console."
    else
        # Failed for some other reason
        echo -e "${YELLOW}WARNING${NC} (Failed with unexpected error)"
        echo "Error: $OUTPUT"
    fi
}

# 1. S3 Create Bucket (Denied)
expect_deny "Create S3 Bucket" "aws s3 mb s3://test-deny-bucket-$(date +%s)"

# 2. EC2 Launch t2.small (Denied Type)
expect_deny "Launch t2.small (Denied Type)" "aws ec2 run-instances --image-id $AMI_US_EAST_1 --instance-type t2.small --region us-east-1 --dry-run"

# 3. EC2 Launch in us-west-1 (Denied Region)
expect_deny "Launch in us-west-1 (Denied Region)" "aws ec2 run-instances --image-id $AMI_US_WEST_1 --instance-type t2.micro --region us-west-1 --dry-run"

# 4. EBS Create 51GB Volume (Denied Size)
expect_deny "Create 51GB Volume (Denied Size)" "aws ec2 create-volume --availability-zone us-east-1a --size 51 --region us-east-1 --dry-run"

# 5. Key Pair in us-west-1 (Denied Region)
expect_deny "Create Key Pair in us-west-1 (Denied Region)" "aws ec2 create-key-pair --key-name test-deny-key --region us-west-1 --dry-run"

echo "================================================"
echo "Done."
