# Instruqt packer image for K3s
This repo contains the source files to build a K3s image for Instruqt.

What's includes:
- K3s
- Helm
- Kubernetes dashboard
- Systemd service for kubectl proxy
- Bash script to wait for Kubernetes dashboard to start and print the dashboard token (`/usr/bin/start.sh`)

## Current active images
Images are built upon releases on the [K3s repo](https://github.com/rancher/k3s). This is a list of images available:

`instruqt/k3s-v1-17-4`

## How to use this image in config.yml
Use the following config to use this image:
```
version: "2"
virtualmachines:
- name: kubernetes
  image: instruqt/k3s-v1-17-4
  shell: /usr/bin/start.sh
  machine_type: n1-standard-4
```

## How to use this image in the web interface
![Instruqt web interface](./screenshot.jpg "Instruqt web interface")