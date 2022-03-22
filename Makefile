K3S_VERSION ?= latest

build: check-variables
	packer build -var 'k3s_version=v1.23.4+k3s1' k3s.pkr.hcl
