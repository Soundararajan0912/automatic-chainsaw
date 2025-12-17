#!/bin/bash

# Simple AWS IAM Policy Test
# A lighter version of the test suite

echo "Running Simple AWS Policy Tests..."

# Helper to get a valid AMI
get_ami() {
    aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[0].ImageId" --output text --region "$1" 2>/dev/null
}

AMI_ID=$(get_ami us-east-1)
if [ -z "$AMI_ID" ] || [ "$AMI_ID" == "None" ]; then AMI_ID="ami-0c02fb55956c7d316"; fi

echo "Using AMI: $AMI_ID"

# Function to run command
run_test() {
    echo "Testing: $1"
    # Capture both stdout and stderr
    OUTPUT=$(eval "$2" 2>&1)
    EXIT_CODE=$?
    
    # Check for Access Denied explicitly
    if echo "$OUTPUT" | grep -qE "AccessDenied|UnauthorizedOperation|AuthFailure"; then
        echo "Result: DENIED"
    elif echo "$OUTPUT" | grep -q "DryRunOperation"; then
        echo "Result: ALLOWED (Dry Run Success)"
    elif [ $EXIT_CODE -eq 0 ]; then
        echo "Result: ALLOWED"
    else
        # Failed with some other error
        echo "Result: ERROR (Command failed but not AccessDenied)"
        echo "Details: $OUTPUT"
    fi
    echo "--------------------------------"
}

# 1. S3 List (Should be Allowed)
run_test "S3 List Buckets" "aws s3 ls"

# 2. EC2 Run Instances (Should be Allowed for t2.micro us-east-1)
run_test "Launch t2.micro us-east-1" "aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --region us-east-1 --dry-run"

# 3. EC2 Run Instances (Should be Denied for t2.small)
run_test "Launch t2.small (Denied)" "aws ec2 run-instances --image-id $AMI_ID --instance-type t2.small --region us-east-1 --dry-run"

# 4. Create Volume (Should be Allowed for 50GB)
run_test "Create 50GB Volume" "aws ec2 create-volume --availability-zone us-east-1a --size 50 --region us-east-1 --dry-run"

# 5. Create Volume (Should be Denied for 51GB)
run_test "Create 51GB Volume (Denied)" "aws ec2 create-volume --availability-zone us-east-1a --size 51 --region us-east-1 --dry-run"

echo "Done."
