#!/bin/bash

# Check if enough arguments are passed
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <REGION> <AMI_ID> <INSTANCE_TYPE> <KEY_NAME> <SECURITY_GROUP_NAME> <SUBNET_ID> <INSTANCE_NAME>"
    exit 1
fi

# Variables from arguments
REGION=$1
AMI_ID=$2
INSTANCE_TYPE=$3
KEY_NAME=$4
SECURITY_GROUP_NAME=$5
SUBNET_ID=$6
INSTANCE_NAME=$7

# Set AWS region
aws configure set region $REGION

# Get Security Group ID
SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

# Launch EC2 Instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --query 'Instances[0].InstanceId' \
  --output text)

if [ $? -ne 0 ]; then
  echo "Failed to launch EC2 instance."
  exit 1
fi

echo "Launched EC2 Instance: $INSTANCE_ID"

# Tag the EC2 Instance
aws ec2 create-tags \
  --resources $INSTANCE_ID \
  --tags Key=Name,Value=$INSTANCE_NAME

# Output instance details
aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value | [0]]' \
  --output table


