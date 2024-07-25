import boto3
import argparse

# Set up argument parsing
parser = argparse.ArgumentParser(description='Create an EC2 instance without a public IP address.')
parser.add_argument('--image-id', required=True, help='The ID of the AMI.')
parser.add_argument('--subnet-id', required=True, help='The ID of the subnet.')
parser.add_argument('--security-group-id', required=True, help='The ID of the security group.')
parser.add_argument('--key-name', required=True, help='The name of the key pair.')
parser.add_argument('--instance-type', required=True, help='The type of instance.')
parser.add_argument('--instance-name', required=True, help='The name of the instance.')

args = parser.parse_args()

# Initialize a session using Amazon EC2
ec2 = boto3.resource('ec2')

# Create an EC2 instance
instances = ec2.create_instances(
    ImageId=args.image_id,
    MinCount=1,
    MaxCount=1,
    InstanceType=args.instance_type,
    KeyName=args.key_name,
    NetworkInterfaces=[
        {
            'SubnetId': args.subnet_id,
            'AssociatePublicIpAddress': False,  # No public IP
            'DeviceIndex': 0,
            'Groups': [args.security_group_id]
        }
    ],
    TagSpecifications=[
        {
            'ResourceType': 'instance',
            'Tags': [
                {
                    'Key': 'Name',
                    'Value': args.instance_name
                }
            ]
        }
    ]
)

# Wait for the instance to be in running state
instance = instances[0]
instance.wait_until_running()

# Reload the instance attributes to get the private IP
instance.reload()

# Print the instance ID and private IP
print('Created instance with ID: {}'.format(instance.id))
print('Private IP address: {}'.format(instance.private_ip_address))
