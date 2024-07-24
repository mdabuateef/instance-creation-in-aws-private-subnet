#!/bin/bash

# Variables
REGION="ap-south-1"  # Set your AWS region
INSTANCE_ID="i-0acf7d3438135b65a"  # Replace with your EC2 instance ID to terminate

# Set AWS region
aws configure set region $REGION

# Function to clean up resources
cleanup() {
  echo "Terminating Instance: $INSTANCE_ID"
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
  aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
  echo "Terminated Instance: $INSTANCE_ID"
}

# Terminate EC2 Instance
cleanup
