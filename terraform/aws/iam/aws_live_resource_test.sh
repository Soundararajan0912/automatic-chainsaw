#!/bin/bash

# AWS Live Resource Creation Test
# WARNING: This script creates REAL AWS resources which may incur costs.
# It will attempt to clean them up after you verify them.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}WARNING: This script will create REAL resources in us-east-1.${NC}"
echo "Resources to be created:"
echo "- Key Pair"
echo "- Security Group"
echo "- t2.micro EC2 Instance"
echo "- 50GB EBS Volume"
echo ""
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

TIMESTAMP=$(date +%s)
KEY_NAME="test-key-$TIMESTAMP"
SG_NAME="test-sg-$TIMESTAMP"
REGION="us-east-1"
AZ="us-east-1a"

# Helper to get AMI
get_ami() {
    aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[0].ImageId" --output text --region "$1" 2>/dev/null
}

echo "Fetching AMI..."
AMI_ID=$(get_ami $REGION)
if [ -z "$AMI_ID" ] || [ "$AMI_ID" == "None" ]; then AMI_ID="ami-0c02fb55956c7d316"; fi
echo "Using AMI: $AMI_ID"

# 1. Create Key Pair
echo -e "\n${YELLOW}1. Creating Key Pair: $KEY_NAME${NC}"
aws ec2 create-key-pair --key-name "$KEY_NAME" --region "$REGION" --query 'KeyMaterial' --output text > "$KEY_NAME.pem"
chmod 400 "$KEY_NAME.pem"
if [ $? -eq 0 ]; then echo -e "${GREEN}Success${NC}"; else echo -e "${RED}Failed${NC}"; fi

# 2. Create Security Group
echo -e "\n${YELLOW}2. Creating Security Group: $SG_NAME${NC}"
SG_ID=$(aws ec2 create-security-group --group-name "$SG_NAME" --description "Test SG for Policy Validation" --region "$REGION" --query 'GroupId' --output text)
if [ $? -eq 0 ]; then echo -e "${GREEN}Success: $SG_ID${NC}"; else echo -e "${RED}Failed${NC}"; fi

# 3. Run Instance
echo -e "\n${YELLOW}3. Launching Instance (t2.micro)${NC}"
INSTANCE_ID=$(aws ec2 run-instances --image-id "$AMI_ID" --instance-type t2.micro --key-name "$KEY_NAME" --security-group-ids "$SG_ID" --region "$REGION" --query 'Instances[0].InstanceId' --output text)
if [ $? -eq 0 ]; then 
    echo -e "${GREEN}Success: $INSTANCE_ID${NC}"
    echo "Waiting for instance to be running..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
    echo "Instance is running."
else 
    echo -e "${RED}Failed${NC}"
fi

# 4. Create Volume
echo -e "\n${YELLOW}4. Creating 50GB Volume${NC}"
VOLUME_ID=$(aws ec2 create-volume --availability-zone "$AZ" --size 50 --region "$REGION" --query 'VolumeId' --output text)
if [ $? -eq 0 ]; then 
    echo -e "${GREEN}Success: $VOLUME_ID${NC}"
    echo "Waiting for volume to be available..."
    aws ec2 wait volume-available --volume-ids "$VOLUME_ID" --region "$REGION"
    echo "Volume is available."
else 
    echo -e "${RED}Failed${NC}"
fi

echo -e "\n${YELLOW}=========================================${NC}"
echo -e "${GREEN}Resources Created for Manual Verification:${NC}"
echo "Key Pair: $KEY_NAME ($KEY_NAME.pem)"
echo "Security Group: $SG_ID ($SG_NAME)"
echo "Instance: $INSTANCE_ID"
echo "Volume: $VOLUME_ID"
echo -e "${YELLOW}=========================================${NC}"

echo -e "\n${YELLOW}Press ENTER to cleanup all resources...${NC}"
read

echo -e "\n${YELLOW}Cleaning up...${NC}"

# Cleanup Instance
if [ ! -z "$INSTANCE_ID" ]; then
    echo "Terminating Instance: $INSTANCE_ID"
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION" > /dev/null
    echo "Waiting for termination..."
    aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$REGION"
fi

# Cleanup Volume
if [ ! -z "$VOLUME_ID" ]; then
    echo "Deleting Volume: $VOLUME_ID"
    aws ec2 delete-volume --volume-id "$VOLUME_ID" --region "$REGION"
fi

# Cleanup SG
if [ ! -z "$SG_ID" ]; then
    echo "Deleting Security Group: $SG_ID"
    # SG deletion might fail if instance is not fully terminated yet, retry loop could be added but wait should handle it
    aws ec2 delete-security-group --group-id "$SG_ID" --region "$REGION"
fi

# Cleanup Key Pair
echo "Deleting Key Pair: $KEY_NAME"
aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION"
rm -f "$KEY_NAME.pem"

echo -e "${GREEN}Cleanup Complete.${NC}"
