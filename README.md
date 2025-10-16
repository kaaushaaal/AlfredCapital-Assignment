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

## ⚙️ Prerequisites

Make sure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure Subscription
- SSH Key Pair

---

## 2️⃣ Authenticate to Azure

Authenticate your session so Terraform can deploy resources in your Azure account.

```bash
az login
```

---

## 3️⃣ Initialize & Apply Terraform

Run the following commands to initialize and deploy your infrastructure:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### 🏗️ Terraform Creates:

- 🖥️ **Nomad Server VM**  
- 💻 **Two Nomad Client VMs**  
- 🔒 **Azure Bastion Host**  
- 🌐 **Virtual Network, Subnets, and NSGs**

> 🧩 Nomad is automatically installed and configured via **cloud-init scripts** during deployment.

---

## 🔐 Secure Access

All nodes are deployed in **private subnets** for enhanced security.  
Access them securely through **Azure Bastion**.

1. Connect to **Azure Bastion** in the Azure Portal.  
2. SSH into the Nomad Server from Bastion:

```bash
ssh nomadadmin@<nomad-server-private-ip>
```

---

## 🧩 Deploy the Sample Application

A simple **Flask “Hello World”** app is provided as a Nomad job.

**Deploy the app:**
```bash
nomad job run nomad_jobs/flask_app.nomad
```

**Verify the deployment:**
```bash
nomad status
```

---

## 🌐 Access the Nomad UI

You can access the **Nomad Web UI** securely using SSH tunneling through Bastion.

**Create the tunnel:**
```bash
ssh -L 4646:localhost:4646 nomadadmin@<nomad-server-private-ip>
```

Then open in your browser:  
👉 [http://localhost:4646](http://localhost:4646)

---

## 🧱 Scaling the Cluster

To scale Nomad client nodes:

1. Update the variable in **`terraform.tfvars`**:
   ```hcl
   client_count = 3
   ```

2. Apply the changes:
   ```bash
   terraform apply -auto-approve
   ```

Terraform will automatically provision additional Nomad clients and join them to the cluster.

---

## 🛡️ Security Best Practices

- ✅ Deploy nodes in **private subnets**
- ✅ Use **Network Security Groups (NSGs)** for isolation
- ✅ Access resources only via **Azure Bastion**
- ✅ Avoid exposing Nomad or app ports publicly
- ✅ Regularly rotate SSH keys and credentials

---
