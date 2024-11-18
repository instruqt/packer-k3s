variable "k3s_version" {
  type = string
}

variable "project_id" {
	type = string
}

variable "region" {
	type = string
	default = "europe-west1"
}

variable "zone" {
	type = string
	default = "europe-west1-b"
}

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

source "googlecompute" "k3s" {
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  image_family = regex_replace("k3s-${regex_replace(var.k3s_version, "\\+.*$", "")}", "[^a-zA-Z0-9_-]", "-")
  image_name   = regex_replace("k3s-${var.k3s_version}-${uuidv4()}", "[^a-zA-Z0-9_-]", "-")

  source_image_family             = "ubuntu-2204-lts"
  machine_type                    = "n1-standard-4"
  disk_size                       = 20
  disable_default_service_account = true

  ssh_username = "root"
}

build {
  sources = ["source.googlecompute.k3s"]

  provisioner "shell" {
    script = "files/k3s-install.sh"
    environment_vars = [
      "K3S_VERSION=${var.k3s_version}"
    ]
  }

  provisioner "file" {
    sources = [
      "files/k3s.service",
      "files/kubectl-proxy.service",
      "files/kube-dashboard.service",
    ]
    destination = "/etc/systemd/system/"
  }

  provisioner "file" {
    source      = "files/k3s-start.sh"
    destination = "/usr/local/bin/k3s-start.sh"
  }

  provisioner "file" {
    source      = "files/start.sh"
    destination = "/usr/bin/start.sh"
  }

  provisioner "shell" {
    inline = ["mkdir -p /opt/kube-dashboard"]
  }

  provisioner "file" {
    sources = [
      "files/dashboard.yml",
      "files/dashboard-sa.yml",
    ]
    destination = "/opt/kube-dashboard/"
  }
}
