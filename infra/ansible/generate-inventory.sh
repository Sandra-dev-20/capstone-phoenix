#!/bin/bash
CONTROL_PLANE_IP=$(cd ../terraform && terraform output -raw control_plane_public_ip)
WORKER_1_IP=$(cd ../terraform && terraform output -json worker_public_ips | jq -r '.[0]')
WORKER_2_IP=$(cd ../terraform && terraform output -json worker_public_ips | jq -r '.[1]')

cat > inventory.yml << EOF
all:
  children:
    control_plane:
      hosts:
        k3s-server:
          ansible_host: ${CONTROL_PLANE_IP}
    workers:
      hosts:
        k3s-worker-1:
          ansible_host: ${WORKER_1_IP}
        k3s-worker-2:
          ansible_host: ${WORKER_2_IP}
EOF

echo "Inventory generated successfully"
cat inventory.yml
