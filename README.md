# project-bedrock
# Project Bedrock — AWS Cloud Infrastructure & CI/CD Pipeline

![Terraform CI/CD Pipeline](https://github.com/owobuokiki-collab/project-bedrock/actions/workflows/terraform.yml/badge.svg)

## Project Overview

Project Bedrock is an automated, high-availability AWS infrastructure deployment for **InnovateMart Inc.** built using Infrastructure as Code (Terraform) and managed via a GitHub Actions CI/CD pipeline.

The architecture provisions a multi-AZ VPC, a managed Amazon EKS cluster, multi-engine relational and NoSQL databases, an event-driven serverless processing pipeline, and strict IAM access controls.

---

## Architecture Summary

* **Network Infrastructure:** Custom VPC (`10.0.0.0/16`) across two Availability Zones (`us-east-1a`, `us-east-1b`) featuring Public, Private, and Database Subnets with NAT Gateways and Internet Gateway.
* **Container Orchestration:** Amazon EKS Cluster (`project-bedrock-cluster`) running workloads isolated inside the `retail-app` namespace.
* **Database Tier:**
  * Amazon RDS MySQL (`Catalog DB`)
  * Amazon RDS PostgreSQL (`Orders DB`)
  * Amazon DynamoDB (`project-bedrock-carts`)
* **Serverless Event Pipeline:** Amazon S3 Asset Bucket (`bedrock-assets-4rl5um`) triggering an AWS Lambda function (`bedrock-asset-processor`) with operational logging to AWS CloudWatch.
* **Access Control & RBAC:** Restricted developer role (`bedrock-dev-view`) configured via EKS Access Entries and IAM policies scoped strictly to read-only access in the `retail-app` namespace.

---

## CI/CD Pipeline Workflow

The repository relies on GitHub Actions (`.github/workflows/terraform.yml`) for automated testing and deployment:

1. **Pull Requests:** Triggers `terraform fmt`, `terraform validate`, and `terraform plan`.
2. **Push to Main:** Automatically executes `terraform apply -auto-approve` to provision infrastructure changes.

---

## Developer Access & Verification

To verify restricted developer access (`bedrock-dev-view`):

```bash
# Update local kubeconfig with dev-view credentials
AWS_PROFILE=dev-view aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster --kubeconfig ~/.kube/config-dev

# View pods in retail-app (Allowed)
kubectl get pods -n retail-app --kubeconfig ~/.kube/config-dev

# View cluster nodes (Forbidden)
kubectl get nodes --kubeconfig ~/.kube/config-dev

##Output Configuration (grading.json)
Key infrastructure metadata is exported automatically via Terraform outputs to grading.json at the root of the repository:
{
  "assets_bucket_name": { "value": "bedrock-assets-4rl5um" },
  "carts_table_name": { "value": "project-bedrock-carts" },
  "cluster_name": { "value": "project-bedrock-cluster" },
  "region": { "value": "us-east-1" },
  "vpc_id": { "value": "vpc-05bc307445452ca6d" }
}

##Infrastructure Teardown
To destroy provisioned resources and prevent unnecessary AWS charges:
# 1. Empty S3 Buckets
aws s3 rm s3://bedrock-assets-4rl5um --recursive

# 2. Delete Kubernetes Ingress
kubectl delete ingress -n retail-app --all

# 3. Destroy Terraform Resources
cd terraform
terraform destroy -auto-approve
---


