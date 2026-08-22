# Architecture — Phoenix Capstone

## Node Topology
                    Internet
                        |
                DuckDNS (sandietaskapp.duckdns.org)
                        |
                AWS eu-north-1 / VPC 10.0.0.0/16
                        |
    +-------------------+-------------------+
    |                   |                   |


## Request Flow

## Single-Server Assumptions This Design Fixes

| Requirement | Single-server problem | Kubernetes fix |
|---|---|---|
| StatefulSet + PVC | Postgres data lost on restart/redeploy | PVC is independent of the Pod lifecycle |
| 2+ replicas per tier | One crash takes the whole tier down | Second replica keeps serving |
| topologySpreadConstraints | Both replicas could land on the same host | Scheduler forces spread across nodes |
| Migration as a Job | Entrypoint-based migrations race at 2+ replicas | Job runs once, completes, then Deployments start |
| RollingUpdate maxUnavailable:0 | Restart causes a visible gap | New Pod must be Ready before old one terminates |
| HPA | Manual scaling under load | CPU-based autoscaling of backend replicas |
| Multi-node cluster | Node failure = total outage | Pods reschedule onto healthy nodes |
| GitOps (Argo CD) | Manual kubectl apply drifts from source | Git is the source of truth; cluster self-heals to match it |

## Security

- SSH (22): restricted to operator's current IP only
- HTTP/HTTPS (80/443): open to the world (required for app + ACME challenge)
- Kubernetes API (6443): not exposed to 0.0.0.0/0 in the security group; reached only from operator's IP for admin access
- NetworkPolicy: default-deny in `taskapp` namespace; Postgres reachable only from backend; backend reachable only from frontend/ingress
- TLS: Let's Encrypt certificate via cert-manager HTTP01 challenge, auto-renewed
- No root SSH login, password authentication disabled (Ansible base-hardening role)
- Secrets (`taskapp-secrets`) never committed to git; `.gitignore` covers `manifests/secret/`, `*.tfstate`, `kubeconfig`, `*.pem`
