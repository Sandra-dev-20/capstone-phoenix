# Runbook — Phoenix Capstone

## Prerequisites
- AWS CLI configured (eu-north-1)
- Terraform, Ansible, kubectl installed
- SSH key: ~/.ssh/sandy-ts.pem

## Provision From Zero

```bash
# 1. Infrastructure
cd infra/terraform
terraform init
terraform apply

# 2. Note IPs
terraform output

# 3. Point DuckDNS subdomain to control_plane_public_ip (manual step on duckdns.org)

# 4. Generate Ansible inventory
cd ../ansible
./generate-inventory.sh

# 5. Install k3s cluster on all 3 nodes
ansible-playbook site.yml

# 6. Pull kubeconfig and point kubectl at the public IP
scp -i ~/.ssh/sandy-ts.pem ubuntu@<control_plane_ip>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
sed -i "s/127.0.0.1/<control_plane_ip>/g" ~/.kube/config
kubectl get nodes   # expect 3x Ready

# 7. Platform: ingress + cert-manager
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager

# 8. Application manifests, in order
kubectl apply -f manifests/namespace/
kubectl apply -f manifests/configmap/
kubectl apply -f manifests/secret/
kubectl apply -f manifests/postgres/
kubectl wait --for=condition=ready pod/postgres-0 -n taskapp --timeout=120s
kubectl apply -f manifests/migration/job.yml
kubectl wait --for=condition=complete job/db-migration -n taskapp --timeout=120s
kubectl apply -f manifests/backend/
kubectl apply -f manifests/frontend/
kubectl apply -f manifests/ingress/
kubectl apply -f manifests/hpa/
kubectl apply -f manifests/networkpolicy/
kubectl apply -f manifests/pdb/

# 9. GitOps
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl apply -f gitops/argocd-app.yml

# 10. Verify
kubectl get pods -n taskapp -o wide
kubectl get certificate -n taskapp
curl -vI https://sandietaskapp.duckdns.org
```

## Scale

```bash
kubectl scale deployment taskapp-backend --replicas=5 -n taskapp
# or let HPA handle it: kubectl get hpa -n taskapp -w
```

## Roll Back A Bad Deployment

```bash
kubectl rollout history deployment/taskapp-backend -n taskapp
kubectl rollout undo deployment/taskapp-backend -n taskapp
kubectl rollout status deployment/taskapp-backend -n taskapp
```

## Recover From A Dead Worker Node

```bash
kubectl get nodes
kubectl get pods -n taskapp -o wide   # confirm pods rescheduled automatically
```

## Recover From A Dead Backend Pod

Kubernetes restarts it automatically via the Deployment controller.
```bash
kubectl get pods -n taskapp -w
kubectl logs -n taskapp deployment/taskapp-backend
```

## Recover From A Bad Migration

```bash
kubectl delete job db-migration -n taskapp
# fix code / image tag in manifests/migration/job.yml
kubectl apply -f manifests/migration/job.yml
kubectl logs -n taskapp -l job-name=db-migration -f
```

## Destroy Everything

```bash
cd infra/terraform
terraform destroy
```
