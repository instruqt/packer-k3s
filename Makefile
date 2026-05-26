K3S_VERSION ?= latest
PROJECT_ID ?= $(shell gcloud config get project)

build:
	packer build -var 'project_id=${PROJECT_ID}' -var 'k3s_version=${K3S_VERSION}' -only='googlecompute.k3s' k3s.pkr.hcl

build-qemu:
	packer build -var 'project_id=${PROJECT_ID}' -var 'k3s_version=${K3S_VERSION}' -only='qemu.k3s' k3s.pkr.hcl
