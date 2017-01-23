# AWS CloudFormation App Example

Simple CF example.




## Setup

First make sure to put these info to `.make` file
```
PROFILE = <AWS PROFILE NAME>
REGION = eu-west-1 or eu-central-1
AMI_ID = <AMI ID>
KEY_NAME = <SSH KEY NAME>
S3_NAME_SUFFIX = your.unique.name
EC2_BOOTSTRAP_SCRIPT = /full/path/to/your/bootstrap.sh
```

Run `make deps` once. This will create required S3 bucket.




## Operate

Run `make start` to start stack.

Run `make status` to check status of the stack.

Run `make stop` to stop the stack.
