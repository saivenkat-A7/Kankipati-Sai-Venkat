
# Week 3 Extension: Infrastructure as Code, CI/CD & Containerization

This repository documents the implementation tasks completed for the Week 3 extension of the PGSN internship program, covering Terraform-based infrastructure provisioning, modular IaC design, Docker containerization, CI/CD automation with GitHub Actions, AWS deployment automation, and CloudWatch monitoring.

## Learning Objectives

- Provision AWS infrastructure using Terraform.
- Understand Infrastructure as Code (IaC) best practices.
- Build CI/CD pipelines using GitHub Actions.
- Containerize applications using Docker.
- Deploy applications to AWS automatically.
- Implement infrastructure versioning and state management.

## Repository Structure

```
.
├── terraform/                  # Day 1 - Standalone Terraform resources (S3, EC2)
├── terraform-modules/
│   └── modules/
│       ├── vpc/                 # Day 2 - Reusable VPC module
│       ├── security-group/      # Day 2 - Reusable Security Group module
│       └── ec2/                 # Day 2 - Reusable EC2 module
├── docker-demo/                 # Day 3 - Sample Dockerfile and web app
├── .github/workflows/           # Day 4 - GitHub Actions CI/CD pipeline
├── deployment/                  # Day 5 - EC2 + Docker deployment automation
└── README.md
```

---

## Day 1 – Terraform Fundamentals

**Topics:** Infrastructure as Code (IaC), Terraform Architecture, Providers, Resources, Variables, Outputs, Terraform State

**Implementation:**
- Installed Terraform and configured the AWS provider (`ap-south-1`).
- Created an S3 bucket (`my-terraform-bucket-2026-sai-001`) as a Terraform-managed resource.
- Created an EC2 instance (`t3.micro`) using Terraform.
- Replaced hardcoded values with input variables.
- Added an output block to expose the EC2 public IP.
- Verified `terraform destroy` to tear down all provisioned resources cleanly.

**Evidence:**
- `terraform init` completed successfully.
- `terraform apply` created the S3 bucket and confirmed via the AWS S3 console (Asia Pacific – Mumbai, `ap-south-1`).
- EC2 instance `my-ec2-venkat` (`t3.micro`) shown in a `Running` state in the EC2 console.

---

## Day 2 – Modular Infrastructure

**Topics:** Terraform Modules, Remote State, Backend Configuration, Terraform Workspaces

**Implementation:**
- Built a reusable **VPC module** provisioning the VPC, public subnet, internet gateway, route table, and route table association.
- Built a reusable **Security Group module** with rules for HTTP, HTTPS, SSH, and egress traffic.
- Built a reusable **EC2 module** that consumes the VPC and Security Group module outputs.
- Structured the root module to call each child module with environment-specific variables.
- Confirmed remote state handling and workspace separation for Dev/Prod environments.

**Evidence:**
- `terraform apply` for the VPC module: 5 resources added (VPC, IGW, subnet, route table, route table association).
- `terraform apply` for the Security Group module: 5 resources added (security group + 4 rules).
- AWS VPC console confirms the VPC (`vpc-0c8170a34d1ad9c06`) in `Available` state.
- AWS Security Groups console confirms the `launch-wizard-1` security group attached to the module-created VPC.

---

## Day 3 – Docker Fundamentals

**Topics:** Docker Architecture, Docker Images, Containers, Dockerfile, Docker Volumes, Docker Networking

**Implementation:**
- Installed Docker Engine on an Amazon Linux 2023 EC2 instance.
- Started and enabled the Docker service (`systemctl start/enable docker`).
- Authored a Dockerfile based on the official `nginx` image, copying a custom `index.html`.
- Built the image locally as `docker-demo`.
- Ran the container, mapping host port `8080` to container port `80`.
- Verified the running container with `docker ps`.
- Pushed the built image to Docker Hub.

**Evidence:**
- `docker --version` confirms Docker `25.0.14` installed and running.
- `docker build` output shows a successful 2-step build producing image `docker-demo` (161MB).
- `docker run -d -p 8080:80 docker-demo` followed by `docker ps` confirms the container `nice_leakey` is `Up` with port `8080→80` mapped.
- Docker Hub repository `saivenkata7/auth-microservice-auth-service` confirms an earlier image push to the registry.

---

## Day 4 – CI/CD with GitHub Actions

**Topics:** Continuous Integration, Continuous Deployment, GitHub Actions, Workflow Files, Secrets Management

**Implementation:**
- Created the `saivenkat-A7/ci-cd-demo` GitHub repository.
- Configured a GitHub Actions workflow (`CI-CD Pipeline`) triggered on every push.
- Workflow stages: checkout code, set up Node.js, install dependencies, run unit tests, build Docker image, log in to Docker Hub, push Docker image.
- Stored Docker Hub credentials securely as GitHub Actions repository secrets.

**Evidence:**
- Workflow run `Fix test case #2` shows the `build-test` job succeeded in 48 seconds.
- Job step breakdown confirms all stages passed: **Set up job**, **Checkout Code**, **Setup Node**, **Install Dependencies**, **Run Tests**, **Build Docker Image** (27s), **Login to Docker Hub**, **Push Docker Image** (6s), and cleanup steps.
- Docker Hub repository `saivenkata7/myapp` shows a new image pushed automatically by the pipeline ("Last pushed 5 minutes ago").
- The `myapp` repository General page confirms the `latest` tag, with the `docker push saivenkata7/myapp:tagname` command for reference.

---

## Day 5 – AWS Deployment Automation

**Topics:** Code Deployment Strategies, Environment Variables, Deployment Automation

**Implementation:**
- Provisioned an EC2 instance via Terraform for application hosting.
- Used EC2 User Data to automatically install Docker on instance launch.
- Pulled the application image from Docker Hub on the target instance.
- Ran the application container and exposed it on the required port.
- Verified the deployed application was reachable in a browser.

**Evidence:**
- Terraform apply output exposes the deployment outputs:
  - `instance_id = "i-06134c9c74d9d830c"`
  - `instance_public_dns = "ec2-52-66-154-200.ap-south-1.compute.amazonaws.com"`
  - `instance_public_ip = "52.66.154.200"`
- Browser verification at `localhost:3000` (via port-forward/tunnel) displays **"Hello from AWS Docker!"**, confirming the containerized application is running and accessible.

---

## Day 6 – Monitoring & Logging

**Topics:** Docker Logs, CloudWatch Logs, CloudWatch Alarms, Application Monitoring

**Implementation:**
- Installed and configured the CloudWatch Agent on the deployment EC2 instance.
- Enabled per-instance EC2 metrics collection in CloudWatch.
- Reviewed available alarm recommendations for CPU, disk, and status-check metrics.
- Verified metric availability for the Docker-hosted EC2 instance ahead of alarm configuration.

**Evidence:**
- CloudWatch **Metrics** console (`us-east-1`) shows the `EC2` namespace initialized with 44 available per-instance metrics.
- Per-instance metrics for the Docker EC2 instance (`i-064b493b0a391...`) list status-check metrics including `StatusCheckFailed`, `StatusCheckFailed_System`, `StatusCheckFailed_Instance`, `StatusCheckFailed_AttachedEBS`, and `InstanceEBSIOPSExceededCheck`, each ready for alarm configuration.

---

## Day 7 – Final Project

**Project:** Deploy a complete production-ready web application using Terraform, AWS VPC, EC2, Security Groups, IAM Roles, an S3 Backend, Docker, GitHub Actions, and CloudWatch.

### Deliverables
- [x] GitHub Repository
- [x] Terraform Code
- [x] Dockerfile
- [x] GitHub Actions Workflow
- [ ] Architecture Diagram
- [ ] Deployment Guide
- [x] README (this file)
- [x] Screenshots of deployment and monitoring

### Bonus Objectives
- [ ] Use Terraform Modules — *implemented in Day 2 (VPC, Security Group, EC2 modules)*
- [ ] Use Remote Backend
- [ ] Configure HTTPS with Nginx reverse proxy
- [ ] Implement Zero Downtime Deployment
- [ ] Configure Auto Deployment on every Git push — *partially implemented via GitHub Actions push trigger in Day 4*

---

## Summary

| Day | Focus Area | Status |
|-----|-----------|--------|
| 1 | Terraform Fundamentals | ✅ Completed |
| 2 | Modular Infrastructure | ✅ Completed |
| 3 | Docker Fundamentals | ✅ Completed |
| 4 | CI/CD with GitHub Actions | ✅ Completed |
| 5 | AWS Deployment Automation | ✅ Completed |
| 6 | Monitoring & Logging | ✅ Completed (metrics); alarms pending |
| 7 | Final Project | 🔄 In Progress |

## Tools & Technologies

`Terraform` · `AWS (VPC, EC2, S3, Security Groups, CloudWatch)` · `Docker` · `Docker Hub` · `GitHub Actions` · `Amazon Linux 2023` · `Nginx`

## Notes

All screenshots referenced above are stored in the `Week-4` folder of the development environment and document each implementation step exactly as executed, without modification.
