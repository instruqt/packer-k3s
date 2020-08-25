# Instruqt packer image for K3s
This repo contains the source files to build a K3s image for Instruqt.

What's includes:
- K3s
- Helm
- Kubernetes dashboard
- Systemd service for kubectl proxy
- Bash script to wait for Kubernetes dashboard to start and print the dashboard token (`/usr/bin/start.sh`)
- Kubectl completion (see section on how to enable kubectl autocompletion)

## Current active images
Images are built upon releases on the [K3s repo](https://github.com/rancher/k3s). This is a list of images available:

`instruqt/k3s-v1-18-8`

`instruqt/k3s-v1-18-6`

`instruqt/k3s-v1-18-4`

`instruqt/k3s-v1-18-3`

`instruqt/k3s-v1-18-2`

`instruqt/k3s-v1-17-11`

`instruqt/k3s-v1-17-9`

`instruqt/k3s-v1-17-7`

`instruqt/k3s-v1-17-6`

`instruqt/k3s-v1-17-5`

`instruqt/k3s-v1-17-4`

## Usage on Instruqt
There is no need to build this packer image yourself. It has already been built.
We advise you to use machine type `n1-standard-2` or higher to ensure stability.

### How to configure this image in your config.yml
Use the following config in your Instruqt config.yml to use this image:
```
version: "2"
virtualmachines:
- name: kubernetes
  image: instruqt/k3s-v1-18-8
  shell: /usr/bin/start.sh
  machine_type: n1-standard-2
```

### How to configure this image in the web interface
Use the following config in your Instruqt track:
![Instruqt web interface](./screenshot.jpg "Instruqt web interface")

## Enabling kubectl autocompletion
To enable kubectl autocompletion, add the following lines to the `setup` script of your first challenge:
```bash
#!/bin/bash
until [ -f /opt/instruqt/bootstrap/host-bootstrap-completed ]
do
    sleep 1
done

echo "source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
echo "complete -F __start_kubectl k" >> /root/.bashrc
echo "setup completed" >> /root/setup-completed
```