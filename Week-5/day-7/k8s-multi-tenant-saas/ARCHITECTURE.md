# Architecture

## Diagram (text-based, view raw for best alignment)

```
                              ┌─────────────────────────────┐
                              │        Ingress Controller     │
                              │      (NGINX, entry point)     │
                              │        host: saas.local       │
                              └───────────────┬───────────────┘
                                              │
                         ┌────────────────────┼────────────────────┐
                         │  path: /            │  path: /api/*        │
                         ▼                    ▼
              ┌────────────────────┐   ┌────────────────────┐
              │  frontend-service    │   │  backend-service     │
              │  (ClusterIP/NodePort)│   │  (ClusterIP)          │
              └───────────┬──────────┘   └───────────┬──────────┘
                          │                          │
                          ▼                          ▼
              ┌────────────────────┐   ┌────────────────────┐
              │ Frontend Deployment │   │ Backend Deployment    │
              │  3 replicas (Pods)  │   │  3 replicas (Pods)     │
              └────────────────────┘   └───────────┬──────────┘
                                                    │
                                    Reads: ConfigMap (saas-config)
                                    Reads: Secret (saas-secret)
                                                    │
                                                    ▼
                                        ┌────────────────────┐
                                        │  postgres-service    │
                                        │    (ClusterIP)        │
                                        └───────────┬──────────┘
                                                    │
                                                    ▼
                                        ┌────────────────────┐
                                        │ Postgres Deployment   │
                                        │     1 replica          │
                                        │  + PVC (1Gi disk)      │
                                        └────────────────────┘

  NetworkPolicy: only Pods labeled app=backend may reach Postgres on port 5432.
  All of the above lives inside Namespace: saas-app
```

## How a request flows
1. Browser hits `http://saas.local/` -> Ingress Controller reads the Ingress rule.
2. If path is `/api/...`, Ingress forwards to `backend-service` -> load-balanced across 3 backend Pods.
3. Otherwise, Ingress forwards to `frontend-service` -> load-balanced across 3 frontend Pods.
4. Backend Pods read non-secret config (DB host, tenant mode) from the `saas-config` ConfigMap, and secrets (DB password, JWT secret) from `saas-secret`.
5. Backend connects to `postgres-service`, which routes to the single Postgres Pod.
6. Postgres stores tenant data on a Persistent Volume (via PVC) — surviving Pod restarts.
7. NetworkPolicy ensures only the backend can reach Postgres directly — frontend and anything else is blocked at the network layer.

## Multi-tenancy note
This setup assumes tenant isolation happens at the **application/database level** (e.g. one schema per tenant, or a `tenant_id` column) rather than one Kubernetes namespace per tenant. That keeps the cluster simple for this learning project. If you later need hard infrastructure isolation between tenants (e.g. enterprise customers requiring dedicated resources), the next step would be one namespace (or even one cluster) per tenant — a bigger architecture change beyond this project's scope.

## Want a visual (PNG/SVG) diagram instead?
Paste the flow above into [Excalidraw](https://excalidraw.com) or [diagrams.net](https://app.diagrams.net) for a polished picture to include in your submission — 10 minutes of dragging boxes using the layout above.
