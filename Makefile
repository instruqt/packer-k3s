K3S_VERSION ?= latest
PROJECT_ID ?= $(shell gcloud config get project)

build:
	packer build -var 'project_id=${PROJECT_ID}' -var 'k3s_version=${K3S_VERSION}' k3s.pkr.hcl
