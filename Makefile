include .make

ENV ?= tst
PROFILE ?= default
REGION ?= eu-central-1

export AWS_PROFILE=$(PROFILE)
export AWS_REGION=$(REGION)

start:
	aws cloudformation create-stack --stack-name "$(ENV)-foundation" \
		--template-body "file://./aws/cf/foundation.yml" \
		--parameters \
			"ParameterKey=Environment,ParameterValue=$(ENV)" \
			"ParameterKey=Region,ParameterValue=$(REGION)"
	# aws cloudformation create-stack "$(ENV)-app"

update:
	aws cloudformation update-stack

stop:
	aws cloudformation delete-stack --stack-name "$(ENV)-foundation" \
		--template-body "file://./aws/cf/foundation.yml" \
		--parameters \
			"ParameterKey=Environment,ParameterValue=$(ENV)" \
			"ParameterKey=Region,ParameterValue=$(REGION)"

.make:
	@touch .make
