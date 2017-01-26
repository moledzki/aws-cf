include .make

AMI_ID ?= ""
KEY_NAME ?= ""
ENV ?= tst
PROFILE ?= default
REGION ?= eu-central-1
S3_NAME_SUFFIX ?= my.test.example
EC2_BOOTSTRAP_SCRIPT ?= /some/script.sh
RDS_ROOT_PASSWORD ?= defaultstupidpassword

export AWS_PROFILE=$(PROFILE)
export AWS_REGION=$(REGION)

## Ensure dependencies
# Creates S3 bucket for CF templates
deps:
	aws s3 mb s3://cloudformation.$(S3_NAME_SUFFIX)

## Creates New "App" Stack
start: upload
	aws cloudformation create-stack --stack-name "$(ENV)-app-full-stack" \
		--template-body "file://./aws/cf/app-full-stack.yml" \
		--disable-rollback \
		--parameters \
			"ParameterKey=AppImageID,ParameterValue=$(AMI_ID)" \
			"ParameterKey=BootstrapScript,ParameterValue=$(EC2_BOOTSTRAP_SCRIPT)" \
			"ParameterKey=Environment,ParameterValue=$(ENV)" \
			"ParameterKey=KeyName,ParameterValue=$(KEY_NAME)" \
			"ParameterKey=RdsRootPassword,ParameterValue=$(RDS_ROOT_PASSWORD)" \
			"ParameterKey=Region,ParameterValue=$(REGION)" \
			"ParameterKey=TemplatesBucket,ParameterValue=cloudformation.$(S3_NAME_SUFFIX)/app/"

## Deletes "App" Stack
stop:
	aws cloudformation delete-stack --stack-name "$(ENV)-app-full-stack"

## Print stack's status
# Usage: make status
status:
	aws cloudformation describe-stacks \
		--stack-name "$(ENV)-app-full-stack" \
		--query "Stacks[][StackStatus] | []"

## Upload CF Templates to S3
upload:
	aws s3 cp aws/cf/foundation.yml s3://cloudformation.$(S3_NAME_SUFFIX)/app/
	aws s3 cp aws/cf/datastore.yml s3://cloudformation.$(S3_NAME_SUFFIX)/app/
	aws s3 cp aws/cf/app.yml s3://cloudformation.$(S3_NAME_SUFFIX)/app/

## Print this help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		$(MAKEFILE_LIST)

.make:
	@touch .make
