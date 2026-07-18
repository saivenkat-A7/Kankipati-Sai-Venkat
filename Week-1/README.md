# Week 1 Learning: Cloud Computing, SDLC, Linux, Shell Scripting, Git & GitHub

This repository contains notes and concepts learned in **Week 1** of my study plan. It covers **Cloud Computing Basics**, **Software Development Life Cycle (SDLC) Concepts**, **Linux & Shell Scripting Concepts**, and **Git & GitHub**.

---

## Table of Contents

1. [Cloud Computing Basics](#cloud-computing-basics)  
2. [SDLC Concepts](#sdlc-concepts)  
3. [Linux & Shell Scripting Concepts](#linux--shell-scripting-concepts)  
4. [Git & GitHub](#git--github)  

---

## Cloud Computing Basics

**Cloud Computing** is the delivery of computing services over the internet (“the cloud”) which includes servers, storage, databases, networking, software, analytics, and more.

### Key Concepts

- **Deployment Models:**
  - **Public Cloud:** Shared resources over the internet (e.g., AWS, Azure, GCP)
  - **Private Cloud:** Dedicated resources for a single organization
  - **Hybrid Cloud:** Combination of public and private clouds

- **Service Models:**
  - **IaaS (Infrastructure as a Service):** Virtualized computing resources (e.g., EC2)
  - **PaaS (Platform as a Service):** Platform to build/deploy applications (e.g., AWS Elastic Beanstalk)
  - **SaaS (Software as a Service):** Software delivered over the internet (e.g., Gmail, Slack)

- **Key Benefits:**
  - Scalability, Cost Efficiency, Flexibility, Disaster Recovery

- **Practice Tasks:**
  - Creating a free-tier cloud account
  - Launching a simple virtual server

---

## SDLC Concepts

**Software Development Life Cycle (SDLC)** defines the steps for developing high-quality software efficiently.

### SDLC Phases

1. **Requirement Analysis:** Gather and document requirements  
2. **Design:** Architecture, UI/UX, database schema  
3. **Implementation / Coding:** Writing actual code  
4. **Testing:** Verify functionality and fix bugs  
5. **Deployment:** Release software to production  
6. **Maintenance:** Monitor, update, and optimize software  

### SDLC Models

- Waterfall, Agile, V-Model, Spiral  

### Key Points

- Ensures structured development
- Reduces risks
- Improves quality

---

## Linux & Shell Scripting Concepts

**Linux** is an open-source operating system; **Shell Scripting** automates tasks.

### Linux Basics

- **File System Structure:** `/home`, `/etc`, `/var`, `/usr`  
- **Common Commands:** `ls`, `cd`, `pwd`, `mkdir`, `rm`, `chmod`  
- **Process Management:** `ps`, `top`, `kill`  

### Shell Scripting Basics

- **What is a Shell Script?** File with sequential commands executed by the shell  
- **Sample Script:**
```bash
#!/bin/bash
# Script to display date and time
echo "Hello, Sai Venkat!"
echo "Current Date and Time: $(date)"
```


## Git & GitHub

```
git init          # Initialize repository
git status        # Check changes
git add .         # Stage files
git commit -m "message"  # Commit changes
git log           # View commit history
git branch        # View/create branches
git checkout      # Switch branch
git merge         # Merge branches


git remote add origin https://github.com/username/repo.git
git push -u origin main

git clone https://github.com/username/repo.git


```

