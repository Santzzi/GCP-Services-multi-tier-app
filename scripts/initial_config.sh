#!/bin/bash
# setup-gcp-workload-identity.sh

set -e

# Configuration - UPDATE THESE VALUES
PROJECT_ID="your-project-id"
GITHUB_USERNAME="your-github-username" 
REPO_NAME="gcp-multi-tier-devops-portfolio"
BILLING_ACCOUNT="your-billing-account-id"

echo "Setting up Workload Identity Federation for $GITHUB_USERNAME/$REPO_NAME"

# Set current project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable iamcredentials.googleapis.com
gcloud services enable sts.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Get project number
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

# Create Workload Identity Pool
echo "Creating Workload Identity Pool..."
gcloud iam workload-identity-pools create "github-actions" \
    --project="$PROJECT_ID" \
    --location="global" \
    --display-name="GitHub Actions Pool"

# Create Workload Identity Provider
echo "Creating Workload Identity Provider..."
gcloud iam workload-identity-pools providers create-oidc "github" \
    --project="$PROJECT_ID" \
    --location="global" \
    --workload-identity-pool="github-actions" \
    --display-name="GitHub provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com"

# Create service account
echo "Creating service account..."
gcloud iam service-accounts create github-actions \
    --display-name="GitHub Actions" \
    --project="$PROJECT_ID"

# Allow Workload Identity Pool to impersonate service account
echo "Setting up IAM bindings..."
gcloud iam service-accounts add-iam-policy-binding \
    "github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --project="$PROJECT_ID" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions/attribute.repository/$GITHUB_USERNAME/$REPO_NAME"

# Grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor"

# Create Terraform state bucket
echo "Creating Terraform state bucket..."
gsutil mb -p $PROJECT_ID gs://$PROJECT_ID-terraform-state
gsutil versioning set on gs://$PROJECT_ID-terraform-state

echo "Setup complete! Add these to your GitHub repository secrets:"
echo ""
echo "WIF_PROVIDER: projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions/providers/github"
echo "WIF_SERVICE_ACCOUNT: github-actions@$PROJECT_ID.iam.gserviceaccount.com"
echo "TERRAFORM_STATE_BUCKET: $PROJECT_ID-terraform-state"