# Day 3 – Configuration Management

## Plain English recap
- **ConfigMap**: settings that are OK to be seen in plain text (DB host, feature flags, ports).
- **Secret**: sensitive settings (passwords, API keys, JWT secret) stored base64-encoded.
- **PV (Persistent Volume)**: an actual chunk of disk storage in the cluster.
- **PVC (Persistent Volume Claim)**: a "request slip" — your app asks for storage, and Kubernetes finds/attaches a PV to match it. On Minikube, PVCs auto-create their own PV, so you rarely write PVs by hand.

## Why this matters for your app
Without a PVC, your Postgres data is stored inside the container's temporary filesystem — **if the Pod restarts, all your tenant data is gone.** The PVC in `03-postgres-pvc.yaml` fixes this by attaching permanent disk storage.

## Implementation Steps

### 1. Create the ConfigMap
Already written in `k8s-manifests/01-configmap.yaml`. Apply it:
```bash
kubectl apply -f k8s-manifests/01-configmap.yaml
kubectl get configmap saas-config -n saas-app -o yaml
```

### 2. Create the Secret
First, generate real base64 values for your own passwords (don't use the sample ones in production):
```bash
echo -n 'my_real_db_password' | base64
```
Paste the output into `k8s-manifests/02-secret.yaml` under `DB_PASSWORD`, then apply:
```bash
kubectl apply -f k8s-manifests/02-secret.yaml
kubectl get secret saas-secret -n saas-app -o yaml
```
To decode and check a value:
```bash
kubectl get secret saas-secret -n saas-app -o jsonpath="{.data.DB_PASSWORD}" | base64 -d
```

### 3. Inject them into Pods
Already wired up in `06-backend-deployment.yaml`:
- `envFrom: configMapRef` pulls in ALL ConfigMap keys as env vars at once.
- Individual `secretKeyRef` entries pull specific Secret keys one at a time (safer than dumping the whole secret).

Verify inside a running Pod:
```bash
kubectl exec -it deployment/backend -n saas-app -- env | grep DB_
```

### 4. Create the PVC (Persistent storage for Postgres)
```bash
kubectl apply -f k8s-manifests/03-postgres-pvc.yaml
kubectl get pvc -n saas-app
```
Status should say `Bound` — meaning storage was successfully attached.

### 5. Mount it into the Postgres container
Already configured in `04-postgres-deployment.yaml` via `volumeMounts` + `volumes`. Apply and confirm:
```bash
kubectl apply -f k8s-manifests/04-postgres-deployment.yaml
kubectl describe pod -l app=postgres -n saas-app | grep -A5 Mounts
```

### 6. Prove data survives a Pod restart
```bash
# connect and create a test table
kubectl exec -it deployment/postgres -n saas-app -- psql -U saas_user -d saas_db -c "CREATE TABLE test_survival(id int);"

# delete the pod
kubectl delete pod -l app=postgres -n saas-app

# wait for it to come back, then check the table still exists
kubectl exec -it deployment/postgres -n saas-app -- psql -U saas_user -d saas_db -c "\dt"
```

## Checkpoint
"Why is a Secret not fully secure by default?" Answer: base64 is encoding, not encryption — anyone with cluster access can decode it. For real production, use a tool like Sealed Secrets, SOPS, or a cloud secret manager (AWS Secrets Manager, HashiCorp Vault).
