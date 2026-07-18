# Comparison: Same App on Plain EC2 vs. Kubernetes (Minikube/Kind)

| Aspect | Plain EC2 | Kubernetes (Minikube/Kind) |
|---|---|---|
| **Deployment unit** | Single Docker container run manually (`docker run ...`) on one VM | Deployment object manages a ReplicaSet of 2 identical Pods |
| **Scaling** | Manual — SSH in, run another container, wire up your own load balancing | Declarative — `kubectl scale deployment myapp-deployment --replicas=5` |
| **Self-healing** | If the container crashes, it stays down until you notice and restart it | Kubernetes' controller loop detects a Pod dying and automatically reschedules a replacement to match the desired replica count |
| **Load balancing** | You'd need to configure Nginx/HAProxy or an ELB yourself in front of multiple containers | The Service (ClusterIP under the hood) automatically load-balances traffic across all matching Pods via label selectors |
| **Networking / exposure** | Security Group rules + public IP/Elastic IP; one container = one host port | NodePort Service opens a consistent port (30000-32767) on every cluster node, decoupled from Pod IPs, which change on every reschedule |
| **Rolling updates** | Manual: pull new image, stop old container, start new one — brief downtime unless you script blue/green yourself | `kubectl set image` / editing the Deployment triggers a rolling update with zero downtime by default (old Pods stay up until new ones pass readiness checks) |
| **Health checks** | Nothing built-in; you'd wire up your own monitoring/alerting (e.g. CloudWatch) | `readinessProbe` / `livenessProbe` are first-class — K8s won't send traffic to a Pod until it's ready, and restarts it if it goes unhealthy |
| **Configuration** | Environment variables set manually in the run command or a `.env` file on the host | Declared in YAML (`deployment.yaml`), version-controllable, reproducible on any cluster |
| **Resource allocation** | Whatever the EC2 instance size gives you, no per-process limits without extra tooling (cgroups manually) | `resources.requests` / `resources.limits` per container, enforced by the kubelet |
| **Infra footprint** | 1 VM = 1 blast radius; if the instance dies, the app is down until you notice | Cluster has multiple nodes (in production); a node failure doesn't take down the whole app since Pods reschedule elsewhere |
| **Cost/complexity for a single small app** | Simpler to reason about, cheaper, less to learn | More moving parts (Deployment, Service, kubelet, controller-manager, etc.) — overkill for a single tiny app, but pays off as the app/team grows |
| **Local dev parity** | EC2 is already "production-like" but not reproducible locally without another EC2 instance | Minikube/Kind let you run essentially the same manifests locally that you'd run on a real cluster (EKS, GKE, etc.), improving dev/prod parity |

## Key takeaway
On EC2, *you* are the orchestrator — every replica, restart, and traffic-routing decision is manual or scripted by hand. On Kubernetes, you describe the **desired state** (2 replicas, exposed via NodePort, with health checks) and the control plane continuously works to keep reality matching that state. The same Docker image runs in both cases — what changes is who's responsible for keeping it running, healthy, and reachable.
