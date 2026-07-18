# Day 5 – Monitoring & Troubleshooting

## Plain English recap
- **Resource requests** = the minimum CPU/memory Kubernetes reserves for your container.
- **Resource limits** = the maximum your container is allowed to use before it's throttled (CPU) or killed (memory -> OOMKilled).
- **Readiness Probe** = "Is this Pod ready to receive traffic RIGHT NOW?" If it fails, the Pod is removed from the Service (no traffic sent), but NOT restarted.
- **Liveness Probe** = "Is this Pod still healthy?" If it fails repeatedly, Kubernetes KILLS and restarts the container.

## Implementation Steps

### 1. Resource requests/limits — already set
Check `06-backend-deployment.yaml` and `04-postgres-deployment.yaml` — both have `resources.requests` and `resources.limits`. Verify:
```bash
kubectl describe pod -l app=backend -n saas-app | grep -A4 Limits
```

### 2. Probes — already configured
Backend and frontend both have `readinessProbe` and `livenessProbe` pointing at `/health` and `/` respectively.

**Important**: your backend needs an actual `/health` route that returns HTTP 200. If it doesn't exist yet, add a simple one, e.g. in Express:
```js
app.get('/health', (req, res) => res.status(200).send('OK'));
```

### 3. Generate a failure on purpose and troubleshoot it
Break the backend image name to simulate a real mistake:
```bash
kubectl set image deployment/backend backend=YOUR_DOCKERHUB_USERNAME/saas-backend:doesnotexist -n saas-app
kubectl get pods -n saas-app
```
You'll see `ImagePullBackOff` or `ErrImagePull`. Now debug it like a real engineer:
```bash
kubectl describe pod <failing-pod-name> -n saas-app     # look at the Events section at the bottom
kubectl get events -n saas-app --sort-by='.lastTimestamp'
```
Fix it:
```bash
kubectl rollout undo deployment/backend -n saas-app
```

### 4. Simulate a crash loop
Temporarily point the liveness probe at a path that doesn't exist and apply it — the Pod will restart forever (`CrashLoopBackOff`). Then check why:
```bash
kubectl describe pod <pod-name> -n saas-app
kubectl logs <pod-name> -n saas-app --previous     # logs from the PREVIOUS crashed container
```
Revert the probe path back to `/health` when done.

### 5. Core debugging commands (your everyday toolkit)
```bash
kubectl get pods -n saas-app                       # quick health overview
kubectl describe pod <name> -n saas-app             # full details + events
kubectl logs <name> -n saas-app                     # current logs
kubectl logs <name> -n saas-app --previous          # logs before last crash
kubectl logs <name> -n saas-app -f                  # follow/live-tail logs
kubectl exec -it <name> -n saas-app -- sh            # shell into the container
kubectl top pods -n saas-app                        # live CPU/memory usage (needs metrics-server)
kubectl get events -n saas-app --sort-by='.lastTimestamp'
```

### 6. Install metrics-server (needed for `kubectl top` and HPA)
```bash
minikube addons enable metrics-server
kubectl top nodes
kubectl top pods -n saas-app
```

## Checkpoint
"Pod shows Running but my app doesn't work — where do you look first?" Answer: `kubectl logs <pod>` first (app-level errors), then `kubectl describe pod` (probe failures, resource issues), then `kubectl get events` (cluster-level scheduling/networking issues).
