#!/bin/bash

# script exit on error
set -e

#########################################################################
#                       AWS environment setup                           #
#########################################################################
export AWS_DEFAULT_REGION='us-east-1'
export AWS_PROFILE='safiad@3265-4859-6406'

#########################################################################
#                          Paramater Values                             #
#########################################################################
# CloudFormation stack name
StackName='PrivateWebApp'

# Environment name for resource identification
Environment=${StackName}

# Prefix of S3 buckets name generated (for static website and access log)
BucketNamePrefix=$(echo -n "$StackName" | tr '[:upper:]' '[:lower:]' | sed 's|[^0-9a-z-]||g')

# Domain name for application (without https://)
DomainName='catwebsite.com'

# Amazon Route 53 private hosted zone ID
HostedZoneID='catwebsite'

# SSL certificate ID for domain name
SSLCertID='REPLACE_ME'

# VPC ID of the VPC where you are deploying the application
VpcID='vpc-60337404'

# Two or more subnet IDs where you want to access the application from
SubnetIDs='vpc-60337404'

# CIDR address range allowed to access the application
IngressCidr='172.16.0.0/16'

######################### Deployment commands ###########################
#                     DO NOT EDIT BELOW THIS LINE                       #
#########################################################################

#########################################################################
# Deploy CloudFormation stack                                           #
#########################################################################
aws cloudformation deploy \
    --template-file template.yaml \
    --stack-name ${StackName} \
    --parameter-overrides \
        "Environment=${Environment}" \
        "BucketNamePrefix=${BucketNamePrefix}" \
        "DomainName=${DomainName}" \
        "HostedZoneID=${HostedZoneID}" \
        "SSLCertID=${SSLCertID}" \
        "VpcID=${VpcID}" \
        "SubnetIDs=${SubnetIDs}" \
        "IngressCidr=${IngressCidr}" \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

#########################################################################
# Upload static website to S3 bucket                                    #
#########################################################################
StaticWebsiteBucket=$(aws cloudformation describe-stacks --stack-name ${StackName} --query "Stacks[0].Outputs[?OutputKey=='StaticWebsiteBucket'].OutputValue" --output text)
aws s3 cp --sse --recursive ./static/ s3://${StaticWebsiteBucket}
