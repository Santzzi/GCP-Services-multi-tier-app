cd gcp-multi-tier-devops-portfolio
# GCP Multi-Tier DevOps Portfolio Project

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/GCP-Powered-4285F4?logo=google-cloud)](https://cloud.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A production-ready multi-tier web application deployed on Google Cloud Platform, demonstrating Infrastructure as Code, CI/CD automation, and DevOps best practices.

## 🏗️ Architecture Overview
```
┌─────────────────────────────────────────────────────────────┐
│                       Load Balancer                          │
└─────────────────┬───────────────────────────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    ┌────▼─────┐     ┌────▼─────┐
    │ Frontend │     │ Backend  │
    │   Pods   │     │   Pods   │
    └──────────┘     └────┬─────┘
                          │
                    ┌─────▼──────┐
                    │ Cloud SQL  │
                    │ PostgreSQL │
                    └────────────┘
```

## 🚀 Tech Stack

- **Infrastructure:** Terraform, Google Cloud Platform
- **Container Orchestration:** Google Kubernetes Engine (GKE)
- **Database:** Cloud SQL (PostgreSQL)
- **Storage:** Cloud Storage
- **CI/CD:** GitHub Actions with Workload Identity Federation
- **Monitoring:** Cloud Monitoring & Logging
- **Applications:** 
  - Frontend: React (to be implemented)
  - Backend: Node.js API (to be implemented)

## 📋 Project Status

### ✅ Completed
- [x] GCP Project setup and configuration
- [x] Workload Identity Federation for secure GitHub Actions authentication
- [x] Terraform backend configuration with GCS
- [x] IAM service accounts and permissions
- [x] API enablement automation
- [x] Path-based CI/CD workflows

### 🚧 In Progress
- [ ] VPC networking configuration
- [ ] GKE cluster deployment
- [ ] Cloud SQL database setup
- [ ] Application development and deployment
- [ ] Monitoring and logging setup

## 🎯 Learning Objectives

This project demonstrates proficiency in:

1. **Infrastructure as Code (IaC):**
   - Modular Terraform design
   - State management with remote backends
   - Multi-environment configuration

2. **Cloud Platform Knowledge:**
   - GCP service integration
   - IAM and security best practices
   - Cost optimization strategies

3. **DevOps Practices:**
   - GitOps workflow
   - Automated CI/CD pipelines
   - Container orchestration

4. **Security:**
   - Keyless authentication with Workload Identity Federation
   - Least-privilege access control
   - Secrets management

## 🛠️ Prerequisites

- Google Cloud Platform account with billing enabled
- Terraform >= 1.0
- gcloud CLI
- Git and GitHub account
- kubectl (for Kubernetes management)

## 📦 Repository Structure
```
gcp-multi-tier-devops-portfolio/
├── terraform/
│   ├── environments/
│   │   └── dev/              # Development environment
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── terraform.tfvars.example
│   └── modules/
│       ├── iam/              # Service accounts and permissions
│       ├── networking/       # VPC, subnets, firewall rules
│       ├── gke/              # Kubernetes cluster
│       └── database/         # Cloud SQL
├── .github/
│   └── workflows/            # GitHub Actions CI/CD
├── applications/
│   ├── frontend/             # React application
│   └── backend/              # Node.js API
├── scripts/                  # Utility scripts
└── docs/                     # Documentation
```

## 🏗️ Repository Architecture & Workflow Strategy

### Current Structure: Mono-Repo with Path-Based Triggers

This portfolio project uses a **mono-repository** approach with intelligent CI/CD workflows that trigger only on relevant changes:
```
gcp-multi-tier-devops-portfolio/
├── terraform/              # Infrastructure as Code (DevOps)
│   └── Triggers: infrastructure-*.yml workflows
│
├── applications/
│   ├── frontend/          # React Application (Frontend Team)
│   │   └── Triggers: frontend-*.yml workflow
│   └── backend/           # Node.js API (Backend Team)
│       └── Triggers: backend-*.yml workflow
│
└── .github/workflows/     # CI/CD Pipelines
    ├── infrastructure-plan.yml      # Runs on terraform/** changes
    ├── infrastructure-apply.yml     # Deploys infrastructure
    ├── frontend-build-deploy.yml    # Runs on applications/frontend/** changes
    ├── backend-build-deploy.yml     # Runs on applications/backend/** changes
    └── destroy-infrastructure.yml   # Manual destruction (safety)
```

### Workflow Triggers Explained

#### 🏗️ Infrastructure Changes
```yaml
# Triggers when:
- terraform/** files change
- infrastructure-*.yml workflows change
- setup scripts change

# Actions:
✓ Terraform plan (on PR)
✓ Terraform apply (on merge to main)
✗ Does NOT rebuild applications
```

#### 🎨 Frontend Changes
```yaml
# Triggers when:
- applications/frontend/** files change
- frontend-*.yml workflow changes

# Actions:
✓ Lint & test
✓ Build Docker image
✓ Push to Google Container Registry
✗ Does NOT modify infrastructure
✗ Does NOT rebuild backend
```

#### ⚙️ Backend Changes
```yaml
# Triggers when:
- applications/backend/** files change
- backend-*.yml workflow changes

# Actions:
✓ Lint & test
✓ Build Docker image
✓ Push to Google Container Registry
✗ Does NOT modify infrastructure
✗ Does NOT rebuild frontend
```

### Benefits of This Approach

✅ **Efficient CI/CD**: Only affected components are built/deployed
✅ **Clear Separation**: Infrastructure and applications have independent lifecycles
✅ **Fast Feedback**: Developers get quick feedback on their specific changes
✅ **Cost Effective**: Reduced CI/CD minutes by not running unnecessary builds
✅ **Easy to Navigate**: One repository showcases complete DevOps skills

### Production Considerations

> **Note**: This mono-repo structure is ideal for portfolio/learning projects and small teams. In production environments with larger teams, we would typically use separate repositories for infrastructure and each application component.

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/gcp-multi-tier-devops-portfolio.git
cd gcp-multi-tier-devops-portfolio
```

### 2. Configure Terraform Variables
```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values
```

### 3. Initialize and Apply Terraform
```bash
terraform init
terraform plan
terraform apply
```

### 4. Verify Deployment
```bash
# Check service accounts
gcloud iam service-accounts list --project=YOUR_PROJECT_ID

# Check enabled APIs
gcloud services list --enabled --project=YOUR_PROJECT_ID
```

## 🔐 Security Setup

This project uses **Workload Identity Federation** for secure, keyless authentication between GitHub Actions and GCP. No service account keys are stored in the repository.

For setup instructions, see [docs/deployment-guide.md](docs/deployment-guide.md)

## 📊 Cost Estimation

Estimated monthly costs for development environment:
- GKE Cluster (e2-medium, 2 nodes): ~$50
- Cloud SQL (db-f1-micro): ~$15
- Cloud Storage: ~$1
- Load Balancer: ~$20
- Monitoring & Logging: ~$5

**Total: ~$91/month**

💡 **Cost Optimization:** Use preemptible nodes and auto-scaling to reduce costs during learning.

## 🧪 Testing
```bash
# Terraform validation
cd terraform/environments/dev
terraform fmt -check -recursive
terraform validate

# Infrastructure testing
terraform plan
```

## 📈 Monitoring

Access monitoring dashboards:
```bash
# Get GKE cluster details
gcloud container clusters describe CLUSTER_NAME --zone=us-central1-a

# View logs
gcloud logging read "resource.type=k8s_cluster" --limit 50
```

## 🤝 Contributing

This is a personal portfolio project, but feedback and suggestions are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Best Practices](https://cloud.google.com/architecture/framework)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📧 Contact

**Your Name** - [Your Email] - [Your LinkedIn]

Project Link: [https://github.com/YOUR_USERNAME/gcp-multi-tier-devops-portfolio](https://github.com/YOUR_USERNAME/gcp-multi-tier-devops-portfolio)

---

⭐ **If you find this project helpful, please give it a star!**
