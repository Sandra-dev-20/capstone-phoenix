# Cost — Phoenix Capstone (AWS eu-north-1)

| Resource | Qty | Unit | Monthly |
|---|---|---|---|
| EC2 t3.small (control plane) | 1 | $0.0232/hr | $16.94 |
| EC2 t3.small (workers) | 2 | $0.0232/hr | $33.88 |
| EBS gp3 20GB (root volumes) | 3 | $0.096/GB | $5.76 |
| EBS gp3 10GB (Postgres PVC) | 1 | $0.096/GB | $0.96 |
| S3 (remote state) | 1 | negligible | $0.05 |
| Data transfer out | ~10GB | $0.09/GB | $0.90 |
| **Total** | | | **~$58.49/month** |

## Halving This Cost

Move to Hetzner Cloud: 3x CX22 (2 vCPU/4GB) at ~€4.35/month each = ~€13/month (~$14), roughly 75% cheaper for comparable specs. Alternative on AWS: use Spot Instances for the two worker nodes (control plane stays On-Demand for stability), which typically cuts EC2 cost by 60-70%.
