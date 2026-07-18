# AWS Week 2 — Advanced Compute & Networking

> Production-style AWS infrastructure built across 7 days covering multi-AZ networking, automated EC2 provisioning, load balancing, auto scaling, private connectivity, advanced storage, and observability.


---


---

## Architecture


</svg>
<img width="119" height="150" alt="aws_week2_architecture" src="https://github.com/user-attachments/assets/45c5254e-93ce-4063-bb9b-b61de837318a" />


> **Figure:** Full architecture for Venkat-VPC in ap-southeast-2 — public/private subnets across two AZs, internet-facing ALB, Auto Scaling Group in private subnets, S3 accessed via VPC Endpoint, and CloudWatch observability.

### Architecture Summary

```
Internet
    │
    ▼
Internet Gateway (Venkat-IGW)
    │
    ▼
Application Load Balancer  ──── HTTP :80 ──── WEB-target group
    │                   │
    ▼                   ▼
Public Subnet A       Public Subnet B
(NAT GW, Bastion)    (EC2 venkat, IAM role)
    │
    ▼  [private outbound via NAT GW]
Private Subnet A    Private Subnet B
   EC2 ──────────── EC2          ← Auto Scaling Group (min 1 / desired 2 / max 4)
    │                │
   EBS              EBS          ← gp3 volumes, snapshot snap-04343a6f
    │
    ▼ [VPC Endpoint — no NAT cost]
Amazon S3 (sai-venkat)           ← versioning + lifecycle policy
    
CloudWatch ← Flow logs + Agent metrics (CPU, mem, disk)
```

---

## Features

- **Multi-AZ VPC** — isolated network with public/private subnet separation across two AZs
- **Internet Gateway + NAT Gateway** — controlled inbound and private outbound internet access
- **Application Load Balancer** — internet-facing, health-checked, distributes traffic to ASG instances
- **Auto Scaling Group** — automatically replaces failed instances; min 1, desired 2, max 4
- **Launch Template** — repeatable, version-controlled EC2 configuration with User Data
- **IAM Roles** — EC2-S3-ReadOnly attached to instances; no embedded credentials
- **Bastion Host + Session Manager** — two methods for private instance access, port-22-free option
- **EBS Volumes + Snapshots** — gp3 data volumes mounted at `/data`, snapshot-based restore tested
- **S3 Static Website** — portfolio site at `sai-venkat.s3-website-ap-southeast-2.amazonaws.com`
- **S3 Versioning + Lifecycle** — Standard → Standard-IA at 30 days → Glacier at 90 days
- **VPC Endpoint (Gateway)** — private S3 access without NAT Gateway data charges
- **VPC Flow Logs** — all traffic captured to CloudWatch Logs for audit
- **CloudWatch Agent** — custom metrics: memory, disk, per-core CPU

---

## Tech Stack

| Layer | Service | Detail |
|---|---|---|
| Networking | Amazon VPC | 10.0.0.0/16, 2 AZs |
| Compute | Amazon EC2 | t3.micro, Amazon Linux 2023 |
| Load balancing | ALB | HTTP :80, WEB-target group |
| Auto scaling | EC2 Auto Scaling | Launch template my-template |
| Identity | AWS IAM | EC2-S3-ReadOnly role |
| Storage (block) | Amazon EBS | gp3, 3000 IOPS, 125 MB/s |
| Storage (object) | Amazon S3 | Versioning, lifecycle, static hosting |
| Private connectivity | VPC Endpoint | Gateway type for S3 |
| Observability | Amazon CloudWatch | Metrics, Logs, Flow Logs |
| Remote access | AWS Systems Manager | Session Manager (no SSH) |
| Web server | Nginx | Installed via User Data |

---

## Infrastructure Overview

### VPC & Subnets

| Resource | ID | CIDR / Detail |
|---|---|---|
| VPC | vpc-0cdd8e18511086210 | 10.0.0.0/16 |
| Public Subnet A | subnet-0e81e692dc3735b9e | ap-southeast-2a |
| Public Subnet B | subnet-0062ae10b082f72e8 | ap-southeast-2b |
| Private Subnet A | — | ap-southeast-2a |
| Private Subnet B | subnet-0b9b4490b375827fa | ap-southeast-2b |
| Internet Gateway | igw-044432dca951d6106 | Attached to Venkat-VPC |
| NAT Gateway | — | Elastic IP 52.63.90.114 in Public A |

### Routing

| Route Table | Association | 0.0.0.0/0 target |
|---|---|---|
| Public (rtb-05c0c568af262b4a6) | Public A, Public B | igw-044432dca951d6106 |
| Private (rtb-03fd670588c17aa2d) | Private A, Private B | NAT Gateway |

### Compute

| Resource | ID / Name | Detail |
|---|---|---|
| EC2 instance | i-0a7b1c879ec0b5c5d (venkat) | t3.micro, Running, Public IP 3.26.8.242 |
| Launch Template | lt-01d2c5099757085e1 (my-template) | Version 1 |
| Auto Scaling Group | asg | min 1 / desired 2 / max 4 |
| ALB | alb | internet-facing, apse2-az1 + apse2-az3 |
| Target Group | WEB-target | HTTP :80, /health check |

### Storage

| Resource | ID | Detail |
|---|---|---|
| EBS Volume | vol-0fca728793dfe41e0 | gp3, 7 GiB, In-use, 3000 IOPS |
| EBS Volume | vol-08f2487df61c6edce | gp3, 8 GiB |
| EBS Volume | vol-0dd6baa1e56713c7b | gp3, 5 GiB |
| EBS Snapshot | snap-04343a6f20fddb691 | 100% complete, taken 2026-06-14 |
| S3 Bucket | sai-venkat | Versioning ON, static hosting enabled |

### Connectivity & Observability

| Resource | ID | Detail |
|---|---|---|
| VPC Endpoint | vpce-0270afb4c96108c73 (ep) | Gateway, S3, Available |
| VPC Flow Log | fl-0f7363dd522cccba9 (fl) | All traffic → CloudWatch Logs |
| IAM Role | EC2-S3-ReadOnly | arn:aws:iam::556834267956:role/EC2-S3-ReadOnly |

---


## Setup & Deployment

### Prerequisites

- AWS account with IAM permissions for EC2, VPC, S3, IAM, CloudWatch
- AWS CLI v2 configured (`aws configure`)
- SSH key pair created in ap-southeast-2
- Your public IP for SSH restriction (`curl ifconfig.me`)

### 1 — Create the VPC

```bash
# Create VPC
aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=Venkat-VPC}]' \
  --region ap-southeast-2

# Enable DNS resolution
aws ec2 modify-vpc-attribute --vpc-id <VPC_ID> --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id <VPC_ID> --enable-dns-hostnames
```

### 2 — Create Subnets

```bash
# Public Subnet A (AZ: ap-southeast-2a)
aws ec2 create-subnet \
  --vpc-id <VPC_ID> \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ap-southeast-2a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-A}]'

# Public Subnet B (AZ: ap-southeast-2b)
aws ec2 create-subnet \
  --vpc-id <VPC_ID> \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ap-southeast-2b \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-B}]'

# Private Subnet A
aws ec2 create-subnet \
  --vpc-id <VPC_ID> \
  --cidr-block 10.0.3.0/24 \
  --availability-zone ap-southeast-2a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-A}]'

# Private Subnet B
aws ec2 create-subnet \
  --vpc-id <VPC_ID> \
  --cidr-block 10.0.4.0/24 \
  --availability-zone ap-southeast-2b \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-B}]'
```

### 3 — Internet Gateway

```bash
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=Venkat-IGW}]' \
  --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id <VPC_ID>
```

### 4 — NAT Gateway

```bash
# Allocate Elastic IP
EIP=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)

# Create NAT Gateway in Public Subnet A
aws ec2 create-nat-gateway \
  --subnet-id <PUBLIC_SUBNET_A_ID> \
  --allocation-id $EIP \
  --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=Venkat-NAT}]'
```

### 5 — Route Tables

```bash
# Public route table — default route via IGW
PUBLIC_RT=$(aws ec2 create-route-table --vpc-id <VPC_ID> \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Public}]' \
  --query 'RouteTable.RouteTableId' --output text)

aws ec2 create-route --route-table-id $PUBLIC_RT \
  --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

aws ec2 associate-route-table --route-table-id $PUBLIC_RT --subnet-id <PUBLIC_A_ID>
aws ec2 associate-route-table --route-table-id $PUBLIC_RT --subnet-id <PUBLIC_B_ID>

# Private route table — default route via NAT GW
PRIVATE_RT=$(aws ec2 create-route-table --vpc-id <VPC_ID> \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private}]' \
  --query 'RouteTable.RouteTableId' --output text)

aws ec2 create-route --route-table-id $PRIVATE_RT \
  --destination-cidr-block 0.0.0.0/0 --nat-gateway-id <NAT_GW_ID>
```

### 6 — EC2 User Data (Nginx install)

Save as `userdata/nginx-install.sh`:

```bash
#!/bin/bash
yum update -y
yum install -y nginx
systemctl enable nginx
systemctl start nginx
echo "<h1>Hello from $(hostname -f)</h1>" > /usr/share/nginx/html/index.html
mkdir -p /usr/share/nginx/html
cat > /usr/share/nginx/html/health <<EOF
OK
EOF
```

### 7 — Launch EC2 with IAM Role

```bash
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.micro \
  --key-name <YOUR_KEY_PAIR> \
  --subnet-id <PUBLIC_SUBNET_B_ID> \
  --security-group-ids <SG_ID> \
  --iam-instance-profile Name=EC2-S3-ReadOnly \
  --user-data file://userdata/nginx-install.sh \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=venkat}]'
```

### 8 — Create ALB + Target Group

```bash
# Target group
aws elbv2 create-target-group \
  --name WEB-target \
  --protocol HTTP \
  --port 80 \
  --vpc-id <VPC_ID> \
  --health-check-path /health \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 5 \
  --unhealthy-threshold-count 2

# ALB
aws elbv2 create-load-balancer \
  --name alb \
  --type application \
  --scheme internet-facing \
  --subnets <PUBLIC_A_ID> <PUBLIC_B_ID> \
  --security-groups <ALB_SG_ID>
```

### 9 — VPC Endpoint for S3

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id <VPC_ID> \
  --service-name com.amazonaws.ap-southeast-2.s3 \
  --vpc-endpoint-type Gateway \
  --route-table-ids <PRIVATE_RT_ID> \
  --tag-specifications 'ResourceType=vpc-endpoint,Tags=[{Key=Name,Value=ep}]'
```

### 10 — Enable VPC Flow Logs

```bash
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids <VPC_ID> \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name vpc \
  --deliver-logs-permission-arn <FLOW_LOG_ROLE_ARN>
```

---

## Day-by-Day Implementation

| Day | Topic | Key Outcomes |
|---|---|---|
| 1 | Multi-AZ VPC Design | VPC, 4 subnets, IGW, NAT GW, route tables, Elastic IPs |
| 2 | Automated EC2 Provisioning | IAM role, User Data bootstrap, Nginx verified |
| 3 | Load Balancing & Auto Scaling | ALB, WEB-target, Launch Template, ASG |
| 4 | Private Connectivity | Bastion Host, SSH agent forwarding, Session Manager |
| 5 | Advanced Storage | EBS attach/format/mount, snapshot, S3 versioning & lifecycle |
| 6 | Monitoring & Private Access | VPC Endpoint, Flow Logs, CloudWatch Agent |
| 7 | Architecture Documentation | Diagram, README, traffic flow walkthrough |

---

## Screenshots
<img width="1492" height="452" alt="Screenshot 2026-06-23 140256" src="https://github.com/user-attachments/assets/50f273d0-1c2d-42e4-9c24-12a124b89dd0" />
<img width="1919" height="1075" alt="Screenshot 2026-06-23 140211" src="https://github.com/user-attachments/assets/2124f112-fc6e-459b-9fba-539c543c0e01" />
<img width="1919" height="982" alt="Screenshot 2026-06-23 135837" src="https://github.com/user-attachments/assets/1c519da6-dcf7-4062-b9e5-dd8baf4b3224" />
<img width="1919" height="982" alt="Screenshot 2026-06-23 135837 - Copy" src="https://github.com/user-attachments/assets/19e27f78-96e7-42b1-ab4e-72220e2ae307" />

<img width="1919" height="1079" alt="Screenshot 2026-06-23 135207 - Copy" src="https://github.com/user-attachments/assets/7636129a-8065-4971-82f5-aa1846619f90" />
<img width="1919" height="1079" alt="Screenshot 2026-06-23 135050" src="https://github.com/user-attachments/assets/766c1cab-6227-4569-96ec-701909934d78" />
<img width="1919" height="1079" alt="Screenshot 2026-06-23 135050 - Copy" src="https://github.com/user-attachments/assets/e3aa9a3c-6342-48f4-b75d-b781a590dc5b" />


<img width="1919" height="1079" alt="Screenshot 2026-06-23 144153" src="https://github.com/user-attachments/assets/9790d144-48f8-4fac-a9c9-eb71087770fa" />
<img width="1919" height="1079" alt="Screenshot 2026-06-23 144042" src="https://github.com/user-attachments/assets/02c92df3-2fbc-4056-8c33-6d39e0665b47" />
<img width="1279" height="578" alt="Screenshot 2026-06-23 144034" src="https://github.com/user-attachments/assets/05a68f7b-c696-4eb8-833d-9156e0e826cb" />
<img width="1918" height="1079" alt="Screenshot 2026-06-23 141037" src="https://github.com/user-attachments/assets/72110e5d-dd0a-4637-a06e-f1a71897c2bf" />
<img width="1919" height="863" alt="Screenshot 2026-06-23 140924" src="https://github.com/user-attachments/assets/83848abc-d8f8-4ee1-9f5a-0f18a707de1e" />
<img width="1919" height="863" alt="Screenshot 2026-06-23 140924 - Copy" src="https://github.com/user-attachments/assets/aaf6c01a-d33e-441c-a7e5-554c61e92513" />
<img width="1905" height="922" alt="Screenshot 2026-06-23 140528" src="https://github.com/user-attachments/assets/10436e77-bc78-4fdb-b479-36e37841f0d0" />

---

## Traffic Flow

### Inbound (user request)

```
User browser
    → Internet
    → Internet Gateway (Venkat-IGW)
    → Application Load Balancer (alb)
        [listener: HTTP :80, health check: /health]
    → WEB-target Target Group
    → EC2 instance (Nginx) in Private Subnet A or B
    → HTTP 200 response
```

### Outbound from private subnets (software updates, API calls)

```
EC2 in Private Subnet
    → Private route table (0.0.0.0/0 → NAT GW)
    → NAT Gateway (Elastic IP 52.63.90.114)
    → Internet Gateway
    → Internet
```

### S3 access (private, no NAT cost)

```
EC2 in Private Subnet
    → aws s3 ls s3://sai-venkat
    → VPC Endpoint (vpce-0270afb4c96108c73)
    → Amazon S3 (stays within AWS backbone, no IGW/NAT)
```

### Admin access — Session Manager (no SSH port required)

```
Admin browser / AWS Console
    → AWS Systems Manager
    → SSM Agent on EC2 (no port 22, no bastion needed)
    → Interactive shell session
    → Logged to CloudTrail
```

---

## Security Controls

| Layer | Control | Detail |
|---|---|---|
| Network | Security Groups | ALB SG: 0.0.0.0/0 :80; EC2 SG: ALB SG only |
| Network | Network ACLs | Stateless subnet-level rules |
| Network | Private subnets | No public IPs on private instances |
| Identity | IAM Role | EC2-S3-ReadOnly; no long-term credentials |
| Access | Session Manager | SSH port 22 not opened for admin access |
| Access | Bastion Host | Jump server for legacy SSH workflows |
| Audit | VPC Flow Logs | All traffic logged (accepted + rejected) |
| Audit | CloudTrail | API calls recorded (enabled by default) |
| Data | S3 Endpoint | Private S3 access; traffic never leaves AWS |

---

## Observations

1. **NAT Gateway cost awareness** — NAT Gateways are charged per GB processed. The S3 VPC Endpoint eliminates this cost for S3-bound traffic entirely.

2. **User Data is fire-and-forget** — bootstrap scripts run once at launch; debugging requires CloudWatch Logs (`/var/log/cloud-init-output.log`) or SSM Session Manager.

3. **Health check path matters** — the ALB only routes to instances that return HTTP 200 on `/health`. Misconfigured health checks cause all instances to show Unhealthy even when Nginx is running.

4. **Launch Templates enable versioning** — unlike Launch Configurations, templates are versioned and can be updated without recreating the ASG.

5. **Session Manager is operationally superior to Bastion Hosts** — no SSH key distribution, no open ports, full session audit via CloudTrail, works through VPC Endpoint.

6. **EBS snapshots are incremental** — only changed blocks are stored after the first snapshot, making repeated snapshots cheap for infrequently modified data volumes.

---

## Cost Optimisation Tips

- Release unused Elastic IPs immediately (charged at $0.005/hr when unassociated)
- Delete NAT Gateways when not needed (charged per hour + per GB)
- Use S3 VPC Endpoint to avoid NAT Gateway data processing charges for S3
- Set ASG minimum to 0 for dev/test environments outside working hours
- Use gp3 over gp2 — same baseline performance, ~20% cheaper, IOPS configurable independently

---


