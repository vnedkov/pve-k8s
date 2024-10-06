# Terraform backend

## Setup
### Open an AWS account
If you don't have an AWS account, open a new one. The resource use will qualify for the free tier.
### Create an S3 bucket
Login in AWS console and create a new bucket. Please note, bucket names are globally unique, so choose a name that is unlikely to exist already. Disable public access.
### Create a DynamoDB table
Create a new DynamoDB table with a single column `LockID` of type `string` as a partition key.

## Configure
Edit `pve.s3.tfbackend` file, or create a new one that fits your environment setup
Modify `bucket`, `region` and `dynamodb_table` properties to match the resource names, created in the previous step.
Optionally, change `key` and/or `encrypt` properties.

## Initialize
In a terminal, run the following command from the project's root directory
```
terraform init -backend-config=backends/pve.s3.tfbackend
```