Repository Structure
gcp-multi-tier-devops-portfolio/
├── README.md
├── .github/
│   └── workflows/
│       ├── backend-build-deploy.yml
│       ├── frontend-build-deploy.yml
│       ├── infrastructure-apply.yml
│       ├── infrastructure-destroy.yml
│       └── infrastructure-plan.yml
├── terraform/
│   ├── bootstrap/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── modules/
│   │   ├── networking/
│   │   ├── iam/
│   │   ├── gke/
│   │   └── database/
│   └── environments/
│       └── dev/
│           ├── main.tf
│           ├── variables.tf
│           ├── terraform.tfvars.example
│           └── outputs.tf
|
├── applications/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── src/
│   │   └── k8s/
│   └── backend/
│       ├── Dockerfile
│       ├── src/
│       └── k8s/
├── scripts/
│   ├── setup-gcp-auth.sh
│   └── deploy-apps.sh
└── docs/
    ├── architecture.md
    └── deployment-guide.md


# Architecture Documentation

## Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Infrastructure Components](#infrastructure-components)
4. [Application Architecture](#application-architecture)
5. [CI/CD Pipeline](#cicd-pipeline)
6. [Security & IAM](#security--iam)
7. [Networking](#networking)
8. [Data Flow](#data-flow)
9. [Deployment Strategy](#deployment-strategy)
10. [Monitoring & Observability](#monitoring--observability)
11. [Disaster Recovery](#disaster-recovery)
12. [Cost Optimization](#cost-optimization)

---

## Overview

### Project Purpose
This project demonstrates a production-ready, cloud-native multi-tier application deployment on Google Cloud Platform, showcasing DevOps best practices including Infrastructure as Code, containerization, CI/CD automation, and observability.

### Architecture Style
- **Pattern**: Microservices architecture
- **Deployment**: Container-based on Kubernetes (GKE)
- **Infrastructure**: Declarative Infrastructure as Code (Terraform)
- **CI/CD**: GitOps with GitHub Actions

### Key Technologies
- **Cloud Provider**: Google Cloud Platform (GCP)
- **IaC**: Terraform 1.5+
- **Container Orchestration**: Google Kubernetes Engine (GKE)
- **Database**: Cloud SQL (PostgreSQL)
- **Storage**: Cloud Storage (GCS)
- **CI/CD**: GitHub Actions with Workload Identity Federation
- **Monitoring**: Cloud Monitoring & Logging

---

## System Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Internet / Users                             │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  Cloud Load    │
                    │   Balancer     │
                    │  (Layer 7)     │
                    └────────┬───────┘
                             │
              ┏━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┓
              ▼                              ▼
    ┌──────────────────┐          ┌──────────────────┐
    │   Frontend Pods  │          │   Backend Pods   │
    │   (React App)    │◄────────►│   (Node.js API)  │
    │   Port: 3000     │          │   Port: 8080     │
    └──────────────────┘          └──────────┬───────┘
              │                              │
              │                              ▼
              │                    ┌──────────────────┐
              │                    │  Cloud SQL Proxy │
              │                    └──────────┬───────┘
              │                              │
              │                              ▼
              │                    ┌──────────────────┐
              │                    │    Cloud SQL     │
              │                    │   (PostgreSQL)   │
              │                    │  Private Network │
              │                    └──────────────────┘
              │
              ▼
    ┌──────────────────┐
    │  Cloud Storage   │
    │  Static Assets   │
    └──────────────────┘

    ┌────────────────────────────────────────┐
    │        Monitoring & Logging            │
    ├────────────────────────────────────────┤
    │  - Cloud Monitoring (Metrics)          │
    │  - Cloud Logging (Logs)                │
    │  - Error Reporting                     │
    │  - Cloud Trace (Distributed Tracing)   │
    └────────────────────────────────────────┘
```

### Architecture Layers

#### 1. Presentation Layer
- **Component**: React Frontend
- **Hosting**: GKE Pods
- **Access**: Via Cloud Load Balancer
- **Purpose**: User interface and client-side logic

#### 2. Application Layer
- **Component**: Node.js API
- **Hosting**: GKE Pods
- **Communication**: RESTful API
- **Purpose**: Business logic and data processing

#### 3. Data Layer
- **Component**: Cloud SQL PostgreSQL
- **Access**: Via Cloud SQL Proxy (secure)
- **Backup**: Automated daily backups
- **Purpose**: Persistent data storage

#### 4. Storage Layer
- **Component**: Cloud Storage
- **Purpose**: Static assets, user uploads, backups
- **Access Control**: IAM-based

---

## Infrastructure Components

### GCP Project Structure

```
GCP Organization (if applicable)
└── Project: devops-portfolio-dev-xxxxx
    ├── Compute
    │   └── GKE Cluster
    │       ├── Node Pool (e2-medium × 2)
    │       ├── Frontend Deployment
    │       └── Backend Deployment
    ├── Databases
    │   └── Cloud SQL Instance
    │       └── PostgreSQL Database
    ├── Storage
    │   ├── GCS Bucket (Terraform State)
    │   └── GCS Bucket (Application Assets)
    ├── Networking
    │   ├── VPC Network
    │   ├── Subnets
    │   ├── Firewall Rules
    │   └── Cloud NAT
    └── IAM
        ├── Service Accounts
        ├── Workload Identity Pool
        └── IAM Bindings
```

### Resource Naming Convention

```
Pattern: {service}-{environment}-{purpose}

Examples:
- gke-dev-cluster
- cloudsql-dev-main
- bucket-dev-terraform-state
- sa-dev-gke-nodes
- vpc-dev-main
```

---

## Application Architecture

### Frontend Application

**Technology**: React 18+

**Structure**:
```
applications/frontend/
├── src/
│   ├── components/      # Reusable UI components
│   ├── pages/           # Page components
│   ├── services/        # API communication
│   ├── hooks/           # Custom React hooks
│   └── utils/           # Helper functions
├── public/              # Static assets
├── Dockerfile           # Container definition
└── k8s/                 # Kubernetes manifests
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

**Container Image**: `gcr.io/{project-id}/frontend:latest`

**Deployment Strategy**:
- Rolling updates
- Zero-downtime deployments
- Health checks: /health endpoint

### Backend Application

**Technology**: Node.js + Express

**Structure**:
```
applications/backend/
├── src/
│   ├── controllers/     # Request handlers
│   ├── models/          # Data models
│   ├── routes/          # API routes
│   ├── middleware/      # Express middleware
│   ├── services/        # Business logic
│   └── config/          # Configuration
├── Dockerfile           # Container definition
└── k8s/                 # Kubernetes manifests
    ├── deployment.yaml
    ├── service.yaml
    └── configmap.yaml
```

**Container Image**: `gcr.io/{project-id}/backend:latest`

**API Endpoints**:
- `GET /health` - Health check
- `GET /api/v1/*` - API routes
- `POST /api/v1/*` - Create operations

---

## CI/CD Pipeline

### Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Developer Workflow                        │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
                    ┌──────────────────┐
                    │  Git Push/PR     │
                    │  (GitHub)        │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │Infrastructure│  │  Frontend   │  │   Backend   │
    │  Workflow    │  │  Workflow   │  │  Workflow   │
    └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
           │                │                 │
           ▼                ▼                 ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │  Terraform  │  │  Build      │  │  Build      │
    │  Plan/Apply │  │  Docker     │  │  Docker     │
    └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
           │                │                 │
           ▼                ▼                 ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │  Deploy     │  │  Push to    │  │  Push to    │
    │  to GCP     │  │  GCR        │  │  GCR        │
    └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
           │                │                 │
           └────────────────┼─────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  Deploy to GKE  │
                  │  (kubectl)      │
                  └─────────────────┘
```

### Workflow Triggers

| Workflow | Trigger Path | Action |
|----------|--------------|--------|
| **Infrastructure Plan** | `terraform/**` on PR | Run `terraform plan`, comment on PR |
| **Infrastructure Apply** | `terraform/**` on merge | Run `terraform apply` |
| **Frontend Deploy** | `applications/frontend/**` | Build, test, push image, deploy |
| **Backend Deploy** | `applications/backend/**` | Build, test, push image, deploy |
| **Destroy** | Manual trigger | Destroy infrastructure (confirmation required) |

### Authentication Flow

**Workload Identity Federation** (Keyless):
```
1. GitHub Actions starts
2. GitHub generates OIDC token
3. Token exchanged with GCP STS
4. Temporary credentials issued
5. Workflow authenticates to GCP
6. No service account keys stored!
```

---

## Security & IAM

### Service Accounts

#### 1. GitHub Actions Service Account
```
Name: github-actions@{project-id}.iam.gserviceaccount.com
Purpose: CI/CD pipeline authentication
Permissions:
  - roles/editor (project-level)
  - Can create/modify resources
  - Cannot delete project
```

#### 2. GKE Nodes Service Account
```
Name: gke-nodes-dev@{project-id}.iam.gserviceaccount.com
Purpose: GKE cluster nodes
Permissions:
  - roles/logging.logWriter
  - roles/monitoring.metricWriter
  - roles/monitoring.viewer
  - roles/storage.objectViewer
```

#### 3. Application Service Account
```
Name: app-dev@{project-id}.iam.gserviceaccount.com
Purpose: Application pods (Workload Identity)
Permissions:
  - roles/storage.objectAdmin (application bucket)
  - roles/logging.logWriter
```

#### 4. Cloud SQL Proxy Service Account
```
Name: cloudsql-proxy-dev@{project-id}.iam.gserviceaccount.com
Purpose: Secure database connections
Permissions:
  - roles/cloudsql.client
```

### Security Best Practices Implemented

✅ **No Service Account Keys**: Using Workload Identity Federation
✅ **Least Privilege**: Minimal permissions per service account
✅ **Network Isolation**: Private Cloud SQL, VPC firewall rules
✅ **Secrets Management**: Using Kubernetes Secrets (future: Secret Manager)
✅ **Image Scanning**: Container vulnerability scanning (future)
✅ **HTTPS Only**: TLS termination at load balancer
✅ **Pod Security**: Security contexts defined in manifests

---

## Networking

### VPC Architecture (Future Module)

```
VPC: vpc-dev-main (10.0.0.0/16)
│
├── Subnet: gke-subnet (10.0.1.0/24)
│   ├── GKE Cluster
│   └── Secondary ranges for pods/services
│
├── Subnet: db-subnet (10.0.2.0/24)
│   └── Cloud SQL (Private IP)
│
└── Subnet: management-subnet (10.0.3.0/24)
    └── Bastion host (if needed)

Firewall Rules:
├── allow-health-checks
├── allow-internal
└── deny-all-ingress (default)

Cloud NAT:
└── Provides egress for private resources
```

### Network Flow

```
Internet → Load Balancer → GKE Pods → Cloud SQL Proxy → Cloud SQL
                                    → Cloud Storage
```

---

## Data Flow

### Request Flow Example

```
1. User Request
   ├→ HTTPS Request to: app.example.com
   │
2. Load Balancer
   ├→ TLS Termination
   ├→ Health Check
   ├→ Route to Service
   │
3. Frontend Service
   ├→ Serve React App
   ├→ Static assets from CDN/Storage
   │
4. API Request (from browser)
   ├→ HTTPS to: api.example.com/v1/users
   │
5. Backend Service
   ├→ Authenticate request
   ├→ Process business logic
   ├→ Query database via Cloud SQL Proxy
   │
6. Database
   ├→ Execute SQL query
   ├→ Return results
   │
7. Response
   ├→ JSON response to client
   └→ Logged to Cloud Logging
```

---

## Deployment Strategy

### Infrastructure Deployment

**Strategy**: Blue-Green at infrastructure level
```
1. Terraform plan shows changes
2. Review in Pull Request
3. Merge triggers apply
4. Changes applied incrementally
5. State stored in GCS
```

### Application Deployment

**Strategy**: Rolling updates
```
kubectl rollout strategy:
- maxSurge: 1 (one extra pod during update)
- maxUnavailable: 0 (no downtime)
- readinessProbe: Ensures pod is ready
- livenessProbe: Restarts unhealthy pods
```

**Rollback Procedure**:
```bash
# Rollback deployment
kubectl rollout undo deployment/backend

# Check status
kubectl rollout status deployment/backend

# View history
kubectl rollout history deployment/backend
```

---

## Monitoring & Observability

### Metrics (Cloud Monitoring)

**Infrastructure Metrics**:
- GKE cluster CPU/Memory usage
- Node health and availability
- Pod restart count
- Network throughput

**Application Metrics**:
- HTTP request rate
- Response time (p50, p95, p99)
- Error rate
- API endpoint performance

### Logging (Cloud Logging)

**Log Types**:
- Application logs (stdout/stderr from pods)
- Infrastructure logs (GKE, Load Balancer)
- Audit logs (API calls, IAM changes)
- Security logs (firewall, authentication)

### Alerting (Future)

**Alert Policies**:
- High error rate (> 5%)
- High latency (> 1s p95)
- Pod crash loops
- Database connection failures
- High CPU usage (> 80%)

---

## Disaster Recovery

### Backup Strategy

**Cloud SQL**:
- Automated daily backups (retained 7 days)
- Point-in-time recovery enabled
- Backup window: 2 AM UTC

**Terraform State**:
- Stored in GCS with versioning
- Lifecycle policy: Keep 10 versions
- Backup bucket: Optional replica

**Application Data**:
- User uploads backed up to GCS
- Retention: 30 days

### Recovery Procedures

**Database Recovery**:
```bash
# List backups
gcloud sql backups list --instance=INSTANCE_NAME

# Restore from backup
gcloud sql backups restore BACKUP_ID \
  --backup-instance=SOURCE_INSTANCE \
  --backup-project=PROJECT_ID
```

**Infrastructure Recovery**:
```bash
# Re-apply Terraform
cd terraform/environments/dev
terraform apply

# Redeploy applications
kubectl apply -f applications/*/k8s/
```

### RTO/RPO Targets

- **RTO** (Recovery Time Objective): 1 hour
- **RPO** (Recovery Point Objective): 24 hours (daily backups)

---

## Cost Optimization

### Current Estimated Costs (Monthly)

| Service | Configuration | Cost |
|---------|--------------|------|
| **GKE** | 2 × e2-medium nodes | ~$50 |
| **Cloud SQL** | db-f1-micro | ~$15 |
| **Load Balancer** | Standard | ~$20 |
| **Cloud Storage** | Standard, 50GB | ~$1 |
| **Networking** | Egress, 100GB | ~$10 |
| **Monitoring** | Basic | ~$5 |
| **Total** | | **~$101/month** |

### Optimization Strategies

✅ **Implemented**:
- Using e2-medium instances (cost-effective)
- Single-region deployment
- Automated cleanup of old images

🔄 **Planned**:
- Preemptible nodes for non-production
- GKE Autopilot for auto-scaling
- Committed use discounts for production
- Cloud CDN for static assets
- Object lifecycle policies

---

## Future Enhancements

### Phase 2: Networking
- [ ] VPC with multiple subnets
- [ ] Cloud NAT for egress
- [ ] Private Service Connect
- [ ] Cloud Armor (WAF)

### Phase 3: Advanced Features
- [ ] Secret Manager integration
- [ ] Cloud CDN
- [ ] Cloud Armor
- [ ] Custom domain with SSL
- [ ] Multi-region deployment

### Phase 4: Observability
- [ ] Prometheus + Grafana
- [ ] Distributed tracing (Cloud Trace)
- [ ] Custom dashboards
- [ ] SLO/SLI definitions
- [ ] On-call rotation

### Phase 5: Security Hardening
- [ ] Binary Authorization
- [ ] Vulnerability scanning
- [ ] Network policies
- [ ] Pod Security Policies
- [ ] Audit logging analysis

---

## Architecture Decision Records (ADRs)

### ADR-001: Use GKE instead of Cloud Run
**Decision**: Use Google Kubernetes Engine
**Rationale**: Demonstrates Kubernetes expertise, more control, industry-standard
**Trade-offs**: Higher cost, more complex than Cloud Run

### ADR-002: Mono-repo structure
**Decision**: Single repository for infrastructure + applications
**Rationale**: Easier for portfolio demonstration, simpler for single developer
**Trade-offs**: Would use separate repos in production with teams

### ADR-003: Workload Identity Federation
**Decision**: Use WIF instead of service account keys
**Rationale**: More secure, follows best practices, no key rotation needed
**Trade-offs**: Slightly more complex initial setup

### ADR-004: Terraform over other IaC tools
**Decision**: Use Terraform for infrastructure
**Rationale**: Industry standard, cloud-agnostic, large community
**Trade-offs**: Not GCP-native (vs Deployment Manager)

---

## References

- [GCP Best Practices](https://cloud.google.com/architecture/framework)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [12-Factor App Methodology](https://12factor.net/)
- [CNCF Cloud Native Trail Map](https://landscape.cncf.io/)

---

**Document Version**: 1.0
**Last Updated**: 2025-10-06
**Author**: [Santzzi]
**Project**: GCP Multi-Tier DevOps Portfolio