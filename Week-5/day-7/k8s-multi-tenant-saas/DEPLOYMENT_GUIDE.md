# Deployment Guide — Quick Start

For full explanations, read `day-guides/`. This file is the fast version: copy-paste and go.

## Prerequisites
```bash
minikube start --driver=docker
minikube addons enable ingress
minikube addons enable metrics-server
```

## Step 1: Push your images (skip if already on Docker Hub)
```bash
docker build -t YOUR_DOCKERHUB_USERNAME/saas-backend:v1 ./backend
docker push YOUR_DOCKERHUB_USERNAME/saas-backend:v1

docker build -t YOUR_DOCKERHUB_USERNAME/saas-frontend:v1 ./frontend
docker push YOUR_DOCKERHUB_USERNAME/saas-frontend:v1
```

## Step 2: Edit placeholders
In `k8s-manifests/06-backend-deployment.yaml`, `08-frontend-deployment.yaml`, and `helm-chart/saas-chart/values.yaml`, replace `YOUR_DOCKERHUB_USERNAME` with your real Docker Hub username.

## Step 3: Deploy — pick ONE method

### Method A: Raw kubectl
```bash
kubectl apply -f k8s-manifests/
kubectl get pods -n saas-app -w
```

### Method B: Helm (recommended)
```bash
helm install saas-release helm-chart/saas-chart/
kubectl get pods -n saas-app -w
```

## Step 4: Access your app
```bash
minikube ip
```
Add to your hosts file:
```
<minikube-ip>   saas.local
```
Open `http://saas.local` in your browser.

## Step 5: Verify everything
```bash
kubectl get all -n saas-app
kubectl get ingress -n saas-app
kubectl get pvc -n saas-app
kubectl logs deployment/backend -n saas-app
```

## Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| `ImagePullBackOff` | Wrong image name or private repo | Check image name spelling; `docker login` + make repo public, or add an imagePullSecret |
| Pod `CrashLoopBackOff` | App crashes on startup | `kubectl logs <pod> --previous` to see the error |
| `Pending` PVC | No default StorageClass | Run `kubectl get storageclass`; on Minikube this should exist by default |
| Ingress returns 404 | Wrong host in `/etc/hosts` or Ingress Controller not ready | Confirm `kubectl get pods -n ingress-nginx` shows Running |
| Backend can't reach Postgres | NetworkPolicy too strict, or wrong DB_HOST | Confirm `DB_HOST=postgres-service` in ConfigMap matches the Service name |

## Tear down
```bash
helm uninstall saas-release -n saas-app     # if using Helm
# OR
kubectl delete -f k8s-manifests/            # if using raw YAML

minikube stop
```
