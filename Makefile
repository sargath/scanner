arg = $(filter-out $@,$(MAKECMDGOALS))

########################
### GLOBAL VARIABLES ###
########################

GO_PACKAGES := $(shell go list ./...)
GO_FILES := $(shell find . -type f -name '*.go' -not -path "./vendor/*")

###########
### APP ###
###########

install: ## install vendor dependencies
	dep ensure -v -vendor-only

#############
### TOOLS ###
#############

fmt: ## run gofmt command
	gofmt -s -l -w ${GO_FILES}

#####################
### STATIC CHECKS ###
#####################

static-check: static-check-vet static-check-lint ## run all static checks

static-check-vet: ## run go vet static check
	go vet ${GO_PACKAGES}

static-check-lint: ## run golangci-lint
	golangci-lint run --disable-all --deadline=30m --skip-dirs vendor/ -v --print-resources-usage -E errcheck,varcheck,typecheck,deadcode,goconst

############
### TEST ###
############

test: ## run unit tests and generate coverage
	go test -v -race -vet=off -coverprofile=cover.out -covermode=atomic -cover ./pkg/...

test-modules: ## run unit tests and generate coverage
	go test -v -race -vet=off -coverprofile=cover.out -covermode=atomic -cover -mod=vendor ./pkg/...

test-coverage-txt-to-html: ## transform coverage report to html
	go tool cover -html=cover.out -o cover.html
