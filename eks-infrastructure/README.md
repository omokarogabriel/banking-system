# Banking System EKS Infrastructure

This directory contains Terraform configuration to deploy the banking system on AWS using EKS (Elastic Kubernetes Service).

## Architecture

- **EKS Cluster** - Managed Kubernetes service
- **EC2 Node Group** - Worker nodes for running pods
- **RDS MySQL** - Database
- **ECR** - Container registry
- **VPC** - Network isolation with public/private subnets
- **NAT Gateway** - Outbound internet access for private subnets
- **LoadBalancer Services** - External access to applications

## Prerequisites

- AWS CLI configured
- Terraform installed
- kubectl installed
- Docker installed

## Deployment Steps

1. **Initialize Terraform:**
   ```bash
   cd eks-infrastructure
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
   ./deploy-eks.sh
   ```

## Access

After deployment, the script will output LoadBalancer URLs:
- Frontend: `http://<webapp-loadbalancer-url>`
- API: `http://<api-gateway-loadbalancer-url>`

## Kubernetes Management

**Configure kubectl:**
```bash
aws eks update-kubeconfig --region us-east-1 --name banking-cluster
```

**View pods:**
```bash
kubectl get pods -n banking-system
```

**View services:**
```bash
kubectl get services -n banking-system
```

**View logs:**
```bash
kubectl logs -f deployment/api-gateway -n banking-system
```

## Scaling

**Scale deployments:**
```bash
kubectl scale deployment account-service --replicas=3 -n banking-system
```

## Configuration

Update `variables.tf` to customize:
- AWS region
- Instance types
- Node group capacity
- Database password

## Cleanup

To destroy all resources:
```bash
terraform destroy
```