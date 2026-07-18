# Day 7 – Final Kubernetes Project (Your Multi-Tenant SaaS App)

This day ties everything together. By now you should already have your app running from Days 2-6. Day 7 is about polishing it into a presentable, documented project.

## Final Checklist

- [ ] Deployments for frontend, backend, postgres — all Running
- [ ] Services connecting them correctly
- [ ] ConfigMap + Secret injected into backend
- [ ] PVC mounted into postgres, data survives Pod restarts
- [ ] Ingress routing `/` and `/api` correctly
- [ ] Helm chart installs the entire app in one command
- [ ] README explains how to run it
- [ ] Architecture diagram included
- [ ] Screenshots of `kubectl get pods`, working app in browser, `helm list`

## Step-by-step: Build your GitHub images first

Before any of this works, your 3 containers need to be pushed to a registry Kubernetes can pull from (Docker Hub is easiest).

```bash
# from your repo root, inside each service folder
cd backend
docker build -t YOUR_DOCKERHUB_USERNAME/saas-backend:v1 .
docker push YOUR_DOCKERHUB_USERNAME/saas-backend:v1

cd ../frontend
docker build -t YOUR_DOCKERHUB_USERNAME/saas-frontend:v1 .
docker push YOUR_DOCKERHUB_USERNAME/saas-frontend:v1
```
(Postgres uses the official `postgres:15` image — no build needed.)

Then replace `YOUR_DOCKERHUB_USERNAME` in:
- `k8s-manifests/06-backend-deployment.yaml`
- `k8s-manifests/08-frontend-deployment.yaml`
- `helm-chart/saas-chart/values.yaml`

## Deploy the whole thing — Option A: raw manifests
```bash
kubectl apply -f k8s-manifests/
kubectl get all -n saas-app
```

## Deploy the whole thing — Option B: Helm (recommended for the final demo)
```bash
helm install saas-release helm-chart/saas-chart/
kubectl get all -n saas-app
```

## Take your screenshots now
```bash
kubectl get pods -n saas-app
kubectl get svc -n saas-app
kubectl get ingress -n saas-app
helm list -n saas-app
```
Screenshot each of these outputs and the working app in your browser. Save them in `screenshots/`.

## Push everything to GitHub
```bash
cd k8s-multi-tenant-saas
git init
git add .
git commit -m "Add Kubernetes manifests, Helm chart, and deployment docs for multi-tenant SaaS app"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

## Deliverables mapping (what goes where)
| Deliverable | Location in this project |
|---|---|
| Kubernetes YAML manifests | `k8s-manifests/` |
| Custom Helm Chart | `helm-chart/saas-chart/` |
| Architecture Diagram | `ARCHITECTURE.md` |
| Deployment Guide | `DEPLOYMENT_GUIDE.md` |
| README | `README.md` |
| Screenshots | `screenshots/` (add your own) |
| GitHub Repository | push this whole folder to your repo |

You're done! This is now a real, interview-ready DevOps project: multi-tier app, containerized, deployed on Kubernetes, packaged with Helm, secured with NetworkPolicy, and monitored with probes + resource limits.
