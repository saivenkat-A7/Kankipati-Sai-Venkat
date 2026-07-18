# Day 4 — Redeploy the Same App on Kubernetes

This folder contains everything needed to take the app you previously ran on
plain EC2 (as a Docker container) and run it on Kubernetes locally using
**Minikube** or **Kind**.

## Files
```
manifests/
  deployment.yaml   # Deployment: 2 replicas of the same Docker image
  service.yaml       # NodePort Service to expose the Deployment
```

---

## 1. Prerequisites
- Docker installed and running
- One of:
  - [Minikube](https://minikube.sigs.k8s.io/docs/start/)
  - [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- `kubectl` installed

## 2. Build (or reuse) the Docker image
Use the exact same Dockerfile/image you used on EC2 so the comparison is apples-to-apples.

```bash
docker build -t myapp:latest .
```

## 3. Load the image into your local cluster

**Minikube**
```bash
minikube start
minikube image load myapp:latest
```

**Kind**
```bash
kind create cluster --name day4-cluster
kind load docker-image myapp:latest --name day4-cluster
```

> If you're pushing to Docker Hub instead, update `image:` in
> `manifests/deployment.yaml` to `<your-dockerhub-user>/myapp:latest` and
> skip the load step — Kubernetes will pull it directly.

## 4. Apply the manifests
```bash
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
```

## 5. Verify

```bash
kubectl get deployments
kubectl get pods -o wide          # should show 2 Running pods
kubectl get services
```

## 6. Access the app

**Minikube**
```bash
minikube service myapp-service --url
# or, if you set a fixed nodePort:
minikube ip     # then browse to http://<minikube-ip>:30080
```

**Kind**
Kind doesn't expose NodePorts to your host by default. Either:
- Port-forward: `kubectl port-forward svc/myapp-service 8080:80`, then visit `http://localhost:8080`
- Or create the cluster with `extraPortMappings` mapping `30080` on the host to `30080` in the kind config, then visit `http://localhost:30080`

## 7. Clean up
```bash
kubectl delete -f manifests/service.yaml
kubectl delete -f manifests/deployment.yaml
# minikube stop  /  kind delete cluster --name day4-cluster
```

---

See `comparison.md` for how this setup differs from running the same app directly on an EC2 instance.
