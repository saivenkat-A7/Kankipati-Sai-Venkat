# Day 4 – Ingress & Networking

## Plain English recap
- **Ingress** = a smart traffic router / receptionist that sits in front of your Services and routes by URL path or domain (e.g. `/api` -> backend, `/` -> frontend). Without it, you'd need a separate NodePort/LoadBalancer per service.
- **Ingress Controller** = the actual engine that reads Ingress rules and does the routing (most common: NGINX Ingress Controller). Ingress rules do nothing until a controller is installed.
- **Network Policy** = a firewall INSIDE the cluster, controlling which Pods can talk to which other Pods.

## Implementation Steps

### 1. Install an Ingress Controller (on Minikube, it's one command)
```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx     # wait until controller pod is Running
```

### 2. Configure Ingress for your app
Already written in `k8s-manifests/10-ingress.yaml`. It routes:
- `saas.local/api/...` -> backend-service
- `saas.local/...` -> frontend-service

Apply it:
```bash
kubectl apply -f k8s-manifests/10-ingress.yaml
kubectl get ingress -n saas-app
```

### 3. Point your local machine to it
```bash
minikube ip     # copy the IP it prints, e.g. 192.168.49.2
```
Edit your hosts file:
```
# Mac/Linux: sudo nano /etc/hosts
# Windows: C:\Windows\System32\drivers\etc\hosts
192.168.49.2   saas.local
```

### 4. Test path-based routing
```bash
curl http://saas.local/          # should hit the frontend
curl http://saas.local/api/health  # should hit the backend
```
Or just open `http://saas.local` in your browser.

### 5. Create Network Policies
Already written in `k8s-manifests/11-network-policy.yaml` — it blocks everything except backend Pods from reaching Postgres. Apply it:
```bash
kubectl apply -f k8s-manifests/11-network-policy.yaml
```

Test that it works — try connecting to Postgres from the frontend Pod (this should now FAIL/timeout):
```bash
kubectl exec -it deployment/frontend -n saas-app -- nc -zv postgres-service 5432
```
Then confirm the backend Pod CAN still connect (this should succeed):
```bash
kubectl exec -it deployment/backend -n saas-app -- nc -zv postgres-service 5432
```

> Note: Minikube's default network driver must support NetworkPolicy (Calico/Cilium). If nothing gets blocked, your CNI plugin may not enforce policies — this is a common Minikube limitation, not a mistake in your YAML.

## Checkpoint
"Why put Postgres behind a NetworkPolicy at all — isn't ClusterIP already private?" Answer: ClusterIP just means it's unreachable from OUTSIDE the cluster. Any Pod INSIDE the cluster (including a compromised or misconfigured one) can still reach it unless a NetworkPolicy explicitly blocks that. This matters a lot for a multi-tenant app where a DB breach affects every tenant.
