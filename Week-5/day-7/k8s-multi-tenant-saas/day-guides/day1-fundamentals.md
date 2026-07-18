# Day 1 – Kubernetes Fundamentals

## What is Kubernetes? (Simple explanation)
Imagine you have 3 containers: frontend, backend, and postgres. Right now you probably run them with `docker-compose up`. That works fine on ONE laptop.

Kubernetes (K8s) is a system that runs your containers across many machines, restarts them if they crash, spreads traffic across copies, and heals itself. Think of it as "docker-compose, but for production, with a robot babysitter."

## Core Concepts (in plain English)

| Term | Simple meaning |
|---|---|
| **Cluster** | A group of computers (nodes) working together |
| **Node** | One computer/VM in the cluster |
| **Pod** | The smallest unit — usually 1 container wrapped in a Pod |
| **Deployment** | "Keep N copies of this Pod running, always" |
| **ReplicaSet** | The thing a Deployment uses internally to count/manage Pod copies |
| **Service** | A stable network address for a group of Pods |
| **Namespace** | A folder to keep your resources separated from other projects |

## Control Plane vs Worker Nodes
- **Control Plane** = the "brain" (API server, scheduler, etcd database). Decides WHERE things run.
- **Worker Nodes** = the "hands" — actually run your Pods.

On Minikube/Kind, both roles run on your single laptop, which is perfect for learning.

## Implementation Steps

### 1. Install Minikube (recommended for beginners)
```bash
# Mac
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Windows (PowerShell, run as admin)
choco install minikube
```

### 2. Install kubectl (the command-line tool to talk to Kubernetes)
```bash
# Mac
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Windows
choco install kubernetes-cli
```

### 3. Start your cluster
```bash
minikube start --driver=docker
```

### 4. Verify the cluster is alive
```bash
kubectl cluster-info
kubectl get nodes
```
You should see one node with status `Ready`.

### 5. Deploy a simple test Pod (Nginx)
```bash
kubectl run test-nginx --image=nginx --port=80
```

### 6. Explore it
```bash
kubectl get pods                     # list pods
kubectl describe pod test-nginx      # detailed info: events, IP, container status
kubectl logs test-nginx              # container logs
kubectl exec -it test-nginx -- bash  # open a shell INSIDE the container
kubectl delete pod test-nginx        # clean up when done
```

## Checkpoint
By the end of Day 1 you should be able to answer: "What is the difference between a Pod and a Deployment?"
Answer: A Pod is one running instance. A Deployment manages many Pods and keeps them healthy — you rarely create raw Pods in real projects.
