# Build the official Instruqt K3S images

This repo builds offical Instruqt K3s images, based on the official [k3s releases](https://github.com/k3s-io/k3s/releases).

This runs a daily build, to check for new releases (excluding pre-releases), and builds a new image when there is a new version available.

When run, the `version.sh` script checks to see if Instruqt has the latest
K3S image in GCP. If not, it uses Packer to build it.

## Running locally

Build the container locally

`docker build . -t packer-k3s`

Run the container locally:

```
docker run \
  --volume $HOME/.config/gcloud/:/.config/gcloud/ \
  --env GOOGLE_APPLICATION_CREDENTIALS=/.config/gcloud/application_default_credentials.json \
  packer-k3s
```

To debug image building issues:

```
docker run \
  --volume $HOME/.config/gcloud/:/.config/gcloud/ \
  --env GOOGLE_APPLICATION_CREDENTIALS=/.config/gcloud/application_default_credentials.json \
  -it --entrypoint ash packer-k3s
```

NOTE: Google auth credentials are required to allow the container to query for the existing images. To provide local credentials, you may have to run:

> `gcloud auth login --update-adc`

## K3S image details

The official Instruqt K3S image includes:

- K3s
- Helm
- Kubernetes dashboard

  - To update to the latest dashboard:
    ```
    GITHUB_URL=https://github.com/kubernetes/dashboard/releases
    VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S "${GITHUB_URL}/latest" -o /dev/null | sed -e 's|.*/||')
    curl -sL -o files/dashboard.yml "https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml"
    # Enable skipping login page
    sed -i '/--namespace=kubernetes-dashboard/a \            - --enable-skip-login' files/dashboard.yml
    ```

- Systemd service for kubectl proxy
- Bash script to wait for Kubernetes dashboard to start and print the dashboard token (`/usr/bin/start.sh`)
- Kubectl completion (see section on how to enable kubectl autocompletion)

## Current active images

Images are built upon releases on the [K3s repo](https://github.com/k3s-io/k3s). This is a list of images available:

`instruqt/k3s-v1-33-2`

`instruqt/k3s-v1-32-4`

<details>
  <summary>List of deprecated images</summary>

`instruqt/k3s-v1-31-4`

`instruqt/k3s-v1-30-6`

`instruqt/k3s-v1-29-0`

`instruqt/k3s-v1-28-5`

`instruqt/k3s-v1-27-1`

`instruqt/k3s-v1-26-4`

`instruqt/k3s-v1-25-0`

`instruqt/k3s-v1-24-4`

`instruqt/k3s-v1-21-1`

`instruqt/k3s-v1-20-4`

`instruqt/k3s-v1-19-8`

`instruqt/k3s-v1-18-16`

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

</details>

## Usage on Instruqt

We advise you to use machine type `n1-standard-2` or higher to ensure stability.

Use the following config in your Instruqt `config.yml` to use this image:

```yaml
version: "2"
virtualmachines:
  - name: kubernetes
    image: instruqt/k3s-v1-33-2
    shell: /usr/bin/start.sh
    machine_type: n1-standard-2
```

### How to configure this image in the web interface

Use the following config in your Instruqt track:
![Instruqt web interface](./screenshot.jpg "Instruqt web interface")

## Multi-node clusters

This image supports creating multi-node cluster. Multi-node clusters contain 2 types of machines:

- One Control Plane server
- Zero or more Worker nodes

The configuration for the Control Plane server is exactly the same as for a single node setup. To add a worker node to this cluster:

1. Add another virtual machine, using the same image (e.g. `instruqt/k3s-v1-27-1`)
2. On that VM, add an environment variable `K3S_CONTROL_PLANE_SERVER`. The value must be the hostname of the Control Plane server.

This will switch it's runtime mode to Worker, and will join the cluster defined by the Control Plane server.

### Example config.yml

```yaml
version: "2"
virtualmachines:
  - name: server
    image: instruqt/k3s-v1-33-2
    shell: /usr/bin/start.sh
    machine_type: n1-standard-2
  - name: worker1
    image: instruqt/k3s-v1-33-2
    shell: /bin/bash
    machine_type: n1-standard-2
    environment:
      K3S_CONTROL_PLANE_HOSTNAME: server
  - name: worker2
    image: instruqt/k3s-v1-33-2
    shell: /bin/bash
    machine_type: n1-standard-2
    environment:
      K3S_CONTROL_PLANE_HOSTNAME: server
```

### Hostname resolution

K3s uses CoreDNS for name resolution. By default CoreDNS only resolves DNS names within the cluster. In this image CoreDNS has been configured to use the host resolver as fallback. This means that any hostnames that do not exist within the cluster will be resolved by the host. This allows you to resolve other hosts in the sandbox configuration using their configured hostname.

This is done by setting the resolv-conf env var (`K3S_RESOLV_CONF`) to point to the host's `resolv.conf`.

K3s cluster defined hostnames take precedence over sandbox defined hosts. If there is a duplicate (by running a pod with the same name as a sandbox host), the resolved IP address will be that of the pod.

## Enabling kubectl autocompletion

To enable kubectl autocompletion, add the following lines to the `setup` script of your **first** challenge:

```bash
#!/bin/bash
until [ -f /opt/instruqt/bootstrap/host-bootstrap-completed ]
do
    sleep 1
done

echo "source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
echo "complete -F __start_kubectl k" >> /root/.bashrc
```
