# Day 2 – Deployments & Services

## Key ideas in plain English
- **Deployment**: "I want 3 copies of my backend running, forever. If one dies, replace it automatically."
- **Rolling Update**: When you push a new image version, Kubernetes swaps old Pods for new ones ONE AT A TIME, so your app never goes fully down.
- **Service types**:
  - `ClusterIP` (default) — only reachable INSIDE the cluster. Good for backend/postgres.
  - `NodePort` — opens a fixed port (30000-32767) on every node, reachable from outside. Good for quick testing.
  - `LoadBalancer` — asks your cloud provider (AWS/GCP/Azure) for a real external IP. Doesn't work locally unless you use `minikube tunnel`.

## Implementation Steps (using YOUR project files)

All files are in `k8s-manifests/`. Apply them in order:

```bash
kubectl apply -f k8s-manifests/00-namespace.yaml
kubectl apply -f k8s-manifests/01-configmap.yaml
kubectl apply -f k8s-manifests/02-secret.yaml
kubectl apply -f k8s-manifests/03-postgres-pvc.yaml
kubectl apply -f k8s-manifests/04-postgres-deployment.yaml
kubectl apply -f k8s-manifests/05-postgres-service.yaml
kubectl apply -f k8s-manifests/06-backend-deployment.yaml
kubectl apply -f k8s-manifests/07-backend-service.yaml
kubectl apply -f k8s-manifests/08-frontend-deployment.yaml
kubectl apply -f k8s-manifests/09-frontend-service.yaml
```

Or apply the whole folder at once:
```bash
kubectl apply -f k8s-manifests/
```

### Check everything is running
```bash
kubectl get pods -n saas-app
kubectl get deployments -n saas-app
kubectl get svc -n saas-app
```

### Access the frontend (NodePort)
```bash
minikube service frontend-service -n saas-app --url
```
This prints a URL — open it in your browser.

## Scale the Deployment (3 -> 5 replicas)
```bash
kubectl scale deployment backend --replicas=5 -n saas-app
kubectl get pods -n saas-app -w     # watch new Pods come up live
```

## Perform a rolling update
Say you built a new backend image `v2`:
```bash
kubectl set image deployment/backend backend=YOUR_DOCKERHUB_USERNAME/saas-backend:v2 -n saas-app
kubectl rollout status deployment/backend -n saas-app
```
Watch Pods update one-by-one:
```bash
kubectl get pods -n saas-app -w
```

## Roll back to the previous version
```bash
kubectl rollout undo deployment/backend -n saas-app
kubectl rollout history deployment/backend -n saas-app
```

## Verify high availability
Delete one backend Pod on purpose and watch Kubernetes replace it automatically:
```bash
kubectl get pods -n saas-app -l app=backend
kubectl delete pod <one-backend-pod-name> -n saas-app
kubectl get pods -n saas-app -l app=backend -w
```
You'll see a new Pod appear within seconds — that's self-healing in action.

## Checkpoint
Try explaining out loud: "Why did my app stay online during the rolling update?"
Answer: Kubernetes never kills all old Pods before new ones are ready — `maxUnavailable: 1` guarantees at least most replicas are serving traffic at all times.
