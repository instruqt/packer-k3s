#!/bin/bash +x

METADATA_ENDPOINT="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
K3S_CONTROL_PLANE_HOSTNAME=$(curl -sfH "Metadata-Flavor: Google" "${METADATA_ENDPOINT}/K3S_CONTROL_PLANE_HOSTNAME")
K3S_FLAGS=$(curl -sfH "Metadata-Flavor: Google" "${METADATA_ENDPOINT}/K3S_FLAGS")
K3S_TOKEN=$(curl -sfH "Metadata-Flavor: Google" "${METADATA_ENDPOINT}/K3S_TOKEN")

K3S_CMD=server
K3S_NODE_NAME=$(hostname)
export K3S_NODE_NAME
export K3S_TOKEN

if [ -n "$K3S_CONTROL_PLANE_HOSTNAME" ]; then
    # Run k3s in agent mode
    K3S_CMD=agent

    K3S_CONTROL_PLANE_IP=$(host "$K3S_CONTROL_PLANE_HOSTNAME" | grep ' has address ' | awk '{print $NF}')
    K3S_URL="https://${K3S_CONTROL_PLANE_IP}:6443/"
    export K3S_URL
else
    systemctl enable kubectl-proxy
    systemctl start kubectl-proxy &
    systemctl start kube-dashboard &
fi

/usr/local/bin/k3s "$K3S_CMD" ${K3S_FLAGS}
