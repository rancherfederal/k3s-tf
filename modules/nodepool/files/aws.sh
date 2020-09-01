#!/bin/bash

# AWS CLI
curl -sL "${aws_download_url}" -o /tmp/awscliv2.zip && unzip -qq -d /tmp /tmp/awscliv2.zip && /tmp/aws/install
rm -rf /tmp/aws*

# Set default region for cli as current instances region
aws configure set default.region $(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep '\"region\"' | cut -d\" -f4)

# simpler alternative for getting region from metadata endpoint is below, but it is relatively new and not available on (T)C2S
#aws configure set default.region $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
