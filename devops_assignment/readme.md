````markdown
### Prerequisites
- Kubernetes clusters: `dev-global-cluster-0` and `prd-global-cluster-5`
- ArgoCD installed and configured
- Access to Git repositories for Helm chart and values

# DevOps Assessment – GitOps & Terraform

## Overview
Two independent tasks:

1. **GitOps (Kubernetes + Helm + Argo CD)**  
   Spring Boot API deployed to two clusters (`dev-global-cluster-0`, `prd-global-cluster-5`) via Argo CD ApplicationSet with Helm.  
   The Helm chart is kept simple (no HPA, ingress class, PVC, etc.).

2. **Terraform (GCP)**  
   Highly available cloud infrastructure for a simple web app (web server, database, object storage).
   Kubernetes manifests are applied by Terraform; in a real-world setup, I would use Argo CD or Helm in a separate repository.

---

## 1. GitOps – Kubernetes + Argo CD + Helm

**Key points:**
- Separate repos for Helm chart & environment values.
- ApplicationSet (Go Template + List Generator) for multi-cluster deployment.
- Zero downtime with:
  ```yaml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0

* Automatic Pod restarts on ConfigMap/Secret change (checksum annotation).
* Random Secrets (`randAlphaNum`) injected into Deployment.
* TCP probes on port 8080, PreStop hook for graceful shutdown.
* Ingress with:

  * `/api` → port 8080
  * `/logs` → port 8081
  * `/soap` → port 8082

---

## 2. Terraform – GCP Infrastructure

**Components:**

* **GKE**: Managed by autopilot.
* **Database**: Cloud SQL (PostgreSQL, HA).
* **Storage**: GCS bucket.
* **Networking**: Global HTTP(S) Load Balancer, firewall rules.
* **Monitoring**: CPU usage and error rate 5xx on loadbalancer.
* **Security**: IAM least privilege, dedicated service accounts.

---

## Possible Improvements

* **Autoscaling with KEDA** – event-driven scaling for Kubernetes workloads.
* **Network Policies** – isolate workloads to improve security.
* **Prometheus + Alertmanager** – monitoring and alerting for reliability and SLO tracking.
* **VPN setup** – then we can turn off enable_private_endpoint for GKE.

```
```
````
