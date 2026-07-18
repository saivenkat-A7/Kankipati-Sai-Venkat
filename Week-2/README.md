# Week 2: AWS Compute & Networking



---

## Learning Objectives

- Launch and connect to EC2 instances securely
- Design a custom VPC with public and private subnets
- Configure security groups, route tables, gateways, and Elastic IPs
- Host content on S3 and understand object storage vs block storage (EBS)
- Produce a clear cloud architecture diagram

---

## Daily Breakdown

| Day | Focus |
|-----|-------|
| Day 1 | EC2 basics — launch, SSH, install Nginx/Apache |
| Day 2 | Elastic IP, security groups, public reachability |
| Day 3 | Custom VPC — subnets, Internet Gateway, NAT Gateway |
| Day 4 | S3 static website + EBS volume, snapshot, restore |
| Day 5 | Architecture diagram + README writeup |

---

## Task 2.1 — Web Server on EC2

### Steps Completed

1. Launched a `t2.micro` / `t3.micro` EC2 instance (Amazon Linux 2 / Ubuntu)
2. Created and downloaded a key pair (`.pem` file) for SSH access
3. Connected to the instance via SSH:
   ```bash
   chmod 400 your-key.pem
   ssh -i "your-key.pem" ec2-user@<public-ip>
   ```
4. Installed and started Nginx (or Apache):
   ```bash
   # Nginx
   sudo apt update && sudo apt install -y nginx
   sudo systemctl start nginx && sudo systemctl enable nginx

   # OR Apache
   sudo apt install -y apache2
   sudo systemctl start apache2 && sudo systemctl enable apache2
   ```
5. Served a simple static HTML page from `/var/www/html/index.html`
6. Allocated an Elastic IP and associated it with the instance
7. Verified public reachability by visiting `http://<elastic-ip>` in a browser

### Screenshots


<img width="1919" height="1015" alt="Screenshot 2026-06-12 144643" src="https://github.com/user-attachments/assets/3b00d662-ccbf-4edc-bfe8-360699dfec9f" />
<img width="1914" height="1016" alt="Screenshot 2026-06-12 144825" src="https://github.com/user-attachments/assets/2b092eea-b17a-440f-8624-9eb80fc6333c" />


<img width="1918" height="1018" alt="Screenshot 2026-06-12 150748" src="https://github.com/user-attachments/assets/9754f55a-059e-4fb1-ae89-d5035c6089e0" />
<img width="1917" height="1020" alt="Screenshot 2026-06-12 150138" src="https://github.com/user-attachments/assets/8f1466db-6825-4fd8-87a5-379b54d232bf" />






---

## Task 2.2 — Custom VPC

### Architecture Overview

```
VPC (10.0.0.0/16)
├── Public Subnet  (10.0.1.0/24)  → Internet Gateway → Internet
│   └── EC2 Web Server
└── Private Subnet (10.0.2.0/24) → NAT Gateway → Internet (egress only)
```

### Steps Completed

1. **Created a VPC** with CIDR block `10.0.0.0/16`
2. **Created subnets:**
   - Public Subnet: `10.0.1.0/24` in `us-east-1a` (or your chosen AZ)
   - Private Subnet: `10.0.2.0/24` in the same AZ
3. **Attached an Internet Gateway (IGW)** to the VPC
4. **Created a NAT Gateway** in the public subnet with an Elastic IP
5. **Configured Route Tables:**
   - Public Route Table: `0.0.0.0/0 → IGW` → associated with public subnet
   - Private Route Table: `0.0.0.0/0 → NAT Gateway` → associated with private subnet
6. **Moved the EC2 web server** into the public subnet
7. Verified private subnet egress through NAT Gateway (e.g., `curl` from a private EC2 instance)

### Screenshots

<img width="1919" height="1079" alt="Screenshot 2026-06-13 151553" src="https://github.com/user-attachments/assets/e5feca10-324e-4708-85bf-213d07f6401b" />
<img width="1919" height="1079" alt="Screenshot 2026-06-13 142448" src="https://github.com/user-attachments/assets/92bbd616-b445-42a0-8476-a56bb8b6a6cb" />



---

##  Task 2.3 — Storage Exploration 

### S3 Static Website

1. Created an S3 bucket (globally unique name, e.g., `week2-static-site-yourname`)
2. Enabled **Static Website Hosting** in bucket properties
3. Set bucket policy to allow public read access
4. Uploaded `index.html` and confirmed the site loads via the S3 website endpoint

   **S3 Website Endpoint format:**
   ```
   http://<bucket-name>.s3-website-<region>.amazonaws.com
   ```

### EBS Volume

1. Created a new EBS volume in the same AZ as the EC2 instance
2. Attached the volume to the instance (e.g., `/dev/xvdf`)
3. Formatted, mounted, and wrote data to the volume:
   ```bash
   sudo mkfs -t ext4 /dev/xvdf
   sudo mkdir /data && sudo mount /dev/xvdf /data
   echo "Hello EBS" | sudo tee /data/test.txt
   ```
4. Took a **snapshot** of the volume via AWS Console
5. Restored the snapshot to a new EBS volume and verified data integrity

### Key Difference: Object vs Block Storage

| Feature | S3 (Object Storage) | EBS (Block Storage) |
|---------|--------------------|--------------------|
| Access | Via HTTP/HTTPS URL | Mounted as disk |
| Use Case | Static files, backups, media | OS, databases, apps |
| Attachment | Standalone (no instance needed) | Attached to EC2 |
| Durability | 11 nines (multi-AZ) | Single AZ (by default) |
| Pricing | Per GB stored + requests | Per GB provisioned |

### Screenshots
<img width="1912" height="1079" alt="Screenshot 2026-06-14 124029" src="https://github.com/user-attachments/assets/cdafdb17-a007-4038-b8c4-6d1bdeb78ce4" />
<img width="1919" height="1079" alt="Screenshot 2026-06-14 124036" src="https://github.com/user-attachments/assets/2374cd1d-aecf-4691-8012-98c6e3332493" />

<img width="1919" height="1074" alt="Screenshot 2026-06-14 125936" src="https://github.com/user-attachments/assets/9adb0888-64b5-4ba1-a1a3-1cb4e5d183bf" />
<img width="1731" height="890" alt="Screenshot 2026-06-14 125533" src="https://github.com/user-attachments/assets/59623e72-1854-4014-97ec-063ebe6abd8d" />

<img width="1919" height="1076" alt="Screenshot 2026-06-14 130133" src="https://github.com/user-attachments/assets/b731bb9e-b678-47e1-9560-0ea84ec244f2" />
<img width="1919" height="1079" alt="Screenshot 2026-06-14 130118" src="https://github.com/user-attachments/assets/918838d8-1b63-40ce-90bb-2ddd899c2775" />

---

## Task 2.4 — Architecture Diagram
<img width="1599" height="803" alt="vpc" src="https://github.com/user-attachments/assets/c377dba5-3094-41cb-99f8-e82fe9d4bd9f" />
<img width="1599" height="899" alt="nat" src="https://github.com/user-attachments/assets/7b4135e8-862f-4593-bd4a-b344595087da" />




### Diagram Walkthrough

**Inbound Traffic (Internet → Web Server):**
1. User request hits the **Elastic IP** associated with the EC2 instance
2. Traffic enters the VPC through the **Internet Gateway**
3. The **Public Route Table** routes the request to the **EC2 instance** in the public subnet
4. The **Security Group** allows inbound traffic on ports 80 (HTTP), 443 (HTTPS), and 22 (SSH)
5. Nginx/Apache serves the response back through the same path

**Outbound Traffic from Private Subnet:**
1. A resource in the **Private Subnet** initiates an outbound request (e.g., software update)
2. The **Private Route Table** routes `0.0.0.0/0` to the **NAT Gateway** (in the public subnet)
3. The **NAT Gateway** uses its Elastic IP to forward the request through the **Internet Gateway**
4. The response returns via NAT Gateway — the private resource is never directly reachable from the internet

**S3 Access:**
- Static website content is served directly from **S3** via its public website endpoint
- No EC2 instance required for object storage access

---



## Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [Amazon EC2 User Guide](https://docs.aws.amazon.com/ec2/index.html)
- [Amazon S3 Documentation](https://docs.aws.amazon.com/s3/index.html)
- [AWS Networking Fundamentals](https://aws.amazon.com/getting-started/hands-on/build-vpc-network/)
- [draw.io with AWS Icon Set](https://www.drawio.com/) — use Extras → Edit Diagram or the AWS shape library

---

