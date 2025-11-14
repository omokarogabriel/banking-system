# Banking System AWS Infrastructure

This directory contains Terraform configuration to deploy the banking system on AWS using ECS Fargate.

## Architecture

- **ECS Fargate** - Container orchestration
- **RDS MySQL** - Database
- **Application Load Balancer** - Load balancing and routing
- **ECR** - Container registry
- **VPC** - Network isolation
- **CloudWatch** - Logging

## Prerequisites

- AWS CLI configured
- Terraform installed
- Docker installed

## Deployment Steps

1. **Initialize Terraform:**
   ```bash
   cd infrastructure
   terraform init
   ```

2. **Plan the deployment:**
   ```bash
   terraform plan
   ```

3. **Apply the infrastructure:**
   ```bash
   terraform apply
   ```

4. **Build and deploy applications:**
   ```bash
   ./deploy.sh
   ```

## Access

After deployment, access the application via the Load Balancer DNS name:
- Frontend: `http://<load-balancer-dns>`
- API: `http://<load-balancer-dns>/api`

## Configuration

Update `variables.tf` to customize:
- AWS region
- Database password
- Environment settings

## Cleanup

To destroy all resources:
```bash
terraform destroy
```