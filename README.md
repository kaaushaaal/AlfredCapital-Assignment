# 🚀 MLOps Engineer Test Task — Nomad Cluster Deployment (Azure + Terraform)

## 📘 Overview
This project demonstrates the deployment of a **secure, scalable, and resilient HashiCorp Nomad cluster** on **Microsoft Azure**, fully provisioned using **Terraform**.  
The setup includes one Nomad server and two client nodes, showcasing best practices in **infrastructure automation**, **security**, and **scalability**.

---

## 🏗️ Architecture & Design

### Cluster Components
| Component | Description |
|------------|-------------|
| 🖥️ **Nomad Server VM** | Manages cluster state, job scheduling, and coordination. |
| 💻 **Nomad Client VMs (x2)** | Execute workloads assigned by the Nomad server. |
| 🔐 **Azure Bastion Host** | Provides secure SSH access without exposing public IPs. |
| 🌐 **Networking Stack** | Virtual Network, Subnets, and NSGs for traffic isolation. |
| ⚙️ **Cloud-Init Automation** | Bootstraps Nomad installation and startup on VM creation. |

### Infrastructure Highlights
- **Infrastructure as Code:** Entire environment is defined with Terraform (`main.tf`, `variables.tf`, etc.).
- **Scalable Design:** Client count can be increased by changing a single Terraform variable.
- **Security First:** Bastion host ensures no public SSH; private subnets restrict exposure.
- **Automated Provisioning:** Cloud-init and shell scripts handle setup seamlessly.

---

## 🗂️ Project Structure

<pre>
.
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── cloud-init-server.yaml
├── cloud-init-client.yaml
│
├── nomad_jobs/
│   └── flask_app.nomad
│
└── user_data/
    ├── server_user_data.sh
    └── client_user_data.sh
</pre>

---

## ⚙️ Deployment Guide

### 1️⃣ Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription with sufficient privileges

---

### 2️⃣ Authenticate to Azure
``bash
az login
This command authenticates your session to allow Terraform to deploy resources.

3️⃣ Initialize & Apply Terraform
bash
Copy code
terraform init
terraform plan
terraform apply -auto-approve
This creates:

Nomad Server VM

Two Nomad Client VMs

Azure Bastion Host

Virtual Network, Subnets, and NSGs

Nomad is automatically installed and configured via cloud-init scripts.

🔐 Secure Access
All nodes are deployed in private subnets.
Access them securely through Azure Bastion:

Connect via Azure Bastion in the Azure Portal.

SSH from Bastion to the Nomad Server:

bash
Copy code
ssh nomadadmin@<nomad-server-private-ip>
🧩 Deploy the Sample Application
A simple Flask Hello World app is provided as a Nomad job.

Deploy the job:

bash
Copy code
nomad job run nomad_jobs/flask_app.nomad
Verify the deployment:

bash
Copy code
nomad status
🌐 Access Nomad UI
Access the Nomad UI securely via SSH tunneling through Bastion:

bash
Copy code
ssh -L 4646:localhost:4646 nomadadmin@<nomad-server-private-ip>
Then open in your browser:
👉 http://localhost:4646

🧱 Scaling the Cluster
To scale client nodes:

Update the variable in terraform.tfvars:

hcl
Copy code
client_count = 3
Apply the changes:

bash
Copy code
terraform apply -auto-approve
Terraform automatically provisions additional Nomad clients and joins them to the cluster.

🛡️ Security Best Practices
Private subnets & NSGs enforce isolation

No public SSH — only Bastion-based access

Cloud-init handles secure idempotent setup

Terraform state managed safely via remote backend (recommended)
