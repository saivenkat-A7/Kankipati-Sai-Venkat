# Multi-Tenant SaaS App — Kubernetes Deployment Project

This project takes your existing multi-tenant SaaS application (Frontend + Backend + PostgreSQL, all containerized) and deploys it on Kubernetes, step by step, over 7 days — matching the "Kubernetes Fundamentals & Application Deployment" curriculum.

## What's in this folder

```
k8s-multi-tenant-saas/
├── README.md                    <- you are here
├── ARCHITECTURE.md              <- diagram + explanation of how the pieces connect
├── DEPLOYMENT_GUIDE.md          <- quick-start: deploy everything in 5 minutes
├── day-guides/                  <- full Day 1-7 walkthroughs, simple English, with commands
│   ├── day1-fundamentals.md
│   ├── day2-deployments-services.md
│   ├── day3-config-secrets-storage.md
│   ├── day4-ingress-networking.md
│   ├── day5-monitoring-troubleshooting.md
│   ├── day6-helm.md
│   └── day7-final-project.md
├── k8s-manifests/                <- raw YAML files (apply directly with kubectl)
│   ├── 00-namespace.yaml
│   ├── 01-configmap.yaml
│   ├── 02-secret.yaml
│   ├── 03-postgres-pvc.yaml
│   ├── 04-postgres-deployment.yaml
│   ├── 05-postgres-service.yaml
│   ├── 06-backend-deployment.yaml
│   ├── 07-backend-service.yaml
│   ├── 08-frontend-deployment.yaml
│   ├── 09-frontend-service.yaml
│   ├── 10-ingress.yaml
│   ├── 11-network-policy.yaml
│   └── 12-hpa.yaml               (bonus: autoscaling)
├── helm-chart/saas-chart/        <- the same app, packaged as a Helm chart
│   ├── Chart.yaml
│   ├── values.yaml               <- EDIT THIS to set your image names/replicas/ports
│   └── templates/
└── screenshots/                  <- put your kubectl/browser screenshots here
```

## Before you start — 3 things to edit

1. **`k8s-manifests/06-backend-deployment.yaml`** and **`08-frontend-deployment.yaml`**
   Replace `YOUR_DOCKERHUB_USERNAME/saas-backend:v1` and `saas-frontend:v1` with your real image names.

2. **`k8s-manifests/02-secret.yaml`**
   Replace the sample base64 password with your real one:
   ```bash
   echo -n 'your_real_password' | base64
   ```

3. **`helm-chart/saas-chart/values.yaml`**
   Same image names as step 1, in one central place (used if you deploy via Helm instead of raw YAML).

## Fastest path to a working deployment
See `DEPLOYMENT_GUIDE.md` for the 5-minute version, or work through `day-guides/` for the full learning path with explanations.

## Tech assumptions made (change if different)
- Backend listens on port `5000` and has a `/health` route returning HTTP 200
- Frontend is served on port `80` (typical for an Nginx-served React/Vue build)
- Postgres uses database name `saas_db`, and tenants are separated by schema (`MULTI_TENANT_MODE: schema` in the ConfigMap — change to `row` or `database` if your app isolates tenants differently)

If your actual ports/routes differ, search-and-replace them in `k8s-manifests/` and `helm-chart/saas-chart/values.yaml` — everything else stays the same.
