include .make

AMI_ID ?= ""
KEY_NAME ?= ""
ENV ?= tst
PROFILE ?= default
REGION ?= eu-central-1
S3_NAME_SUFFIX ?= my.test.example

export AWS_PROFILE=$(PROFILE)
export AWS_REGION=$(REGION)

deps:
	aws s3 mb s3://cloudformation.$(S3_NAME_SUFFIX)

## Creates New "App" Stack
start: upload
	aws cloudformation create-stack --stack-name "$(ENV)-app-full-stack" \
		--template-body "file://./aws/cf/app-full-stack.yml" \
		--parameters \
			"ParameterKey=KeyName,ParameterValue=$(KEY_NAME)" \
			"ParameterKey=AppImageID,ParameterValue=$(AMI_ID)" \
			"ParameterKey=Environment,ParameterValue=$(ENV)" \
			"ParameterKey=Region,ParameterValue=$(REGION)" \
			"ParameterKey=TemplatesBucket,ParameterValue=cloudformation.$(S3_NAME_SUFFIX)/app/"

## Deletes "App" Stack
stop:
	aws cloudformation delete-stack --stack-name "$(ENV)-app-full-stack"

## Upload CF Templates to S3
upload:
	aws s3 cp aws/cf/foundation.yml s3://cloudformation.$(S3_NAME_SUFFIX)/app/
	aws s3 cp aws/cf/datastorage.yml s3://cloudformation.$(S3_NAME_SUFFIX)/app/
	aws s3 cp aws/cf/app.yml s3://cloudformation.$(S3_NAME_SUFFIX)/app/

.make:
	@touch .make
