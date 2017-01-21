include .make

AMI_ID ?= ""
KEY_NAME ?= ""
ENV ?= tst
PROFILE ?= default
REGION ?= eu-central-1

export AWS_PROFILE=$(PROFILE)
export AWS_REGION=$(REGION)

## Creates New "App" Stack
start: upload
	aws cloudformation create-stack --stack-name "$(ENV)-app-full-stack" \
		--template-body "file://./aws/cf/app.yml" \
		--parameters \
			"ParameterKey=FoundationStack,ParameterValue=$(ENV)-foundation" \
			"ParameterKey=KeyName,ParameterValue=$(KEY_NAME)" \
			"ParameterKey=AppImageID,ParameterValue=$(AMI_ID)" \
			"ParameterKey=Environment,ParameterValue=$(ENV)" \
			"ParameterKey=Region,ParameterValue=$(REGION)"

## Upload CF Templates to S3
upload:
	aws s3 cb cloudformation.maciek.oledzki.net
	aws s3 cp aws/cf/foundation.yml s3://cloudformation.maciek.oledzki.net/app/
	aws s3 cp aws/cf/datastorage.yml s3://cloudformation.maciek.oledzki.net/app/
	aws s3 cp aws/cf/app.yml s3://cloudformation.maciek.oledzki.net/app/

stop:
	aws cloudformation delete-stack --stack-name "$(ENV)-app-full-stack"

.make:
	@touch .make
