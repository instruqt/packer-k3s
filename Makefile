ts := $(shell /bin/date "+%s")

check-project:
ifndef PROJECT
  $(error PROJECT is undefined)
endif

check-version:
ifndef K3S_VERSION
  $(error K3S_VERSION is undefined. Find your version on https://github.com/k3s-io/k3s, example: v1.17.4)
endif

check-tag:
ifndef K3S_TAG
  $(error K3S_TAG is undefined. Find your tag on https://github.com/k3s-io/k3s, example: v1.17.4+k3s1)
endif

build: check-project check-version check-tag
	packer build -var 'project_id=${PROJECT}' -var "k3s_version=${K3S_VERSION}" -var "k3s_tag=${K3S_TAG}" packer.json

force-build: check-project check-version check-tag
	packer build -force -var 'project_id=${PROJECT}' -var "k3s_version=${K3S_VERSION}" -var "k3s_tag=${K3S_TAG}" packer.json