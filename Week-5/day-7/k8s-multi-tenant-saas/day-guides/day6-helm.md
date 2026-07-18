# Day 6 – Helm Package Manager

## Plain English recap
Helm is like `npm` or `pip`, but for Kubernetes YAML. Instead of applying 10+ separate files by hand, you install ONE "chart" with your custom values.

- **Chart** = a packaged set of Kubernetes templates (this whole `helm-chart/saas-chart/` folder).
- **Templates** = YAML files with `{{ .Values.xxx }}` placeholders instead of hardcoded values.
- **values.yaml** = the single file where you set image names, replica counts, ports, etc.
- **Release** = one deployed instance of a chart (you could deploy the SAME chart twice under different release names for staging vs prod).

## Implementation Steps

### 1. Install Helm
```bash
# Mac
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows
choco install kubernetes-helm
```
Verify:
```bash
helm version
```

### 2. Deploy Nginx using Helm (quick warm-up, unrelated to your app)
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-nginx bitnami/nginx
kubectl get pods
helm uninstall my-nginx
```

### 3. Use YOUR custom chart (already built for you)
The chart lives in `helm-chart/saas-chart/`. First, edit `values.yaml` to set your real image names:
```yaml
backend:
  image: YOUR_DOCKERHUB_USERNAME/saas-backend
  tag: v1
frontend:
  image: YOUR_DOCKERHUB_USERNAME/saas-frontend
  tag: v1
```

Dry-run first to catch YAML errors before touching the cluster:
```bash
helm install saas-release helm-chart/saas-chart/ --dry-run --debug
```

Install for real:
```bash
helm install saas-release helm-chart/saas-chart/
kubectl get all -n saas-app
```

### 4. Parameterize on the fly (override values.yaml from the command line)
Scale replicas or change service type without editing files:
```bash
helm upgrade saas-release helm-chart/saas-chart/ --set backend.replicas=5
helm upgrade saas-release helm-chart/saas-chart/ --set frontend.service.type=LoadBalancer
```

### 5. Upgrade and rollback a release
Bump the backend image tag:
```bash
helm upgrade saas-release helm-chart/saas-chart/ --set backend.tag=v2
helm history saas-release -n saas-app
```
Something broke? Roll back to the previous release:
```bash
helm rollback saas-release 1 -n saas-app
```

### 6. Clean up
```bash
helm uninstall saas-release -n saas-app
```

## Checkpoint
"Why use Helm instead of just `kubectl apply -f k8s-manifests/`?" Answer: Helm gives you versioned releases (easy rollback), one command to deploy everything, and reusable parameters — instead of hand-editing 10 YAML files every time you change an image tag or replica count.
