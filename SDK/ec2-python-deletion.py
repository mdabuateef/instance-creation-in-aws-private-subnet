import boto3
import argparse

# Set up argument parsing
parser = argparse.ArgumentParser(description='Terminate an EC2 instance.')
parser.add_argument('--instance-id', required=True, help='The ID of the instance to terminate.')

args = parser.parse_args()

# Initialize a session using Amazon EC2
ec2 = boto3.client('ec2')

# Terminate the EC2 instance
response = ec2.terminate_instances(InstanceIds=[args.instance_id])

# Print the response
print('Termination response:', response)