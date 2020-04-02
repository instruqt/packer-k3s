#!/bin/sh
trap "clear; exec /bin/bash;" INT TERM

if ! curl --silent --fail --output /dev/null http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/; then
  echo "Starting Kubernetes, this may take a minute or so"
  while ! curl --silent --fail --output /dev/null http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/; do printf "." && sleep 1; done || break
  printf "done."
  echo ""
fi
clear
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token | awk '{ print $2 }' > /root/dashboard-token.txt
echo ""
echo "Your Kubernetes cluster is ready. Use this token to access the Kubernetes Dashboard:"
echo ""
cat /root/dashboard-token.txt
echo ""
echo ""
echo "Copy/paste with Ctrl-Insert/Shift-Insert. You can also find this token at /root/dashboard-token.txt"
echo ""
exec /bin/bash