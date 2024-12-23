# Bank of Anthos on Kubernetes with CI/CD

A complete deployment solution for the Bank of Anthos application, featuring automated CI/CD pipeline and GitOps-based Kubernetes deployment. This project consists of two repositories working together to provide a full development to deployment workflow.

## Project Overview

The project is split across two repositories:

1. [Bank of Anthos Application Build](https://github.com/chandhuDev/bank-of-anthos-app/tree/master)
   - Handles CI/CD pipeline
   - Builds Docker images
   - Automated using Jenkins
   - Pushes images to Docker Hub

2. [Bank of Anthos Kubernetes Deployment](https://github.com/chandhuDev/bank-of-anthos-k8)
   - Contains Kubernetes manifests
   - Uses GitOps with ArgoCD
   - Manages environment configurations
   - Handles automatic image updates

## Architecture

### Microservices
- **Frontend**: Web UI interface
- **Account Services**:
  - Userservice: Authentication & user management
  - Contacts: Contact management
- **Transaction Services**:
  - Ledgerwriter: Writes transactions
  - Balancereader: Checks balances
  - Transactionhistory: Shows transaction history
- **Databases**:
  - Accountsdb: Stores user data
  - Ledgerdb: Stores transactions

### CI/CD Flow
1. Code changes pushed to app repository
2. Jenkins triggers automated build
3. Docker images built and pushed to Docker Hub
4. ArgoCD detects new images
5. Automatic deployment to Kubernetes cluster

## Repository Structures

## Prerequisites

- Kubernetes cluster (1.19+)
- kubectl configured
- ArgoCD installed
- Jenkins server (for CI/CD)
- Docker Hub account

## Deployment Guide

1. Setup Jenkins Pipeline:
   ```bash
   # Configure Jenkins with repository credentials
   # Set up Docker Hub authentication
   # Create pipeline using Jenkinsfile
3. Create Kubernetes Namespace:
   ```bash
   - kubectl create namespace dev
5. Create JWT Secret:
   ```bash
   - kubectl create secret generic jwt-key \
    --from-file=k8-Application/jwtRS256.key \
    --from-file=k8-Application/jwtRS256.key.pub \
    -n dev
6. Deploy via ArgoCD:
   ```bash
   - kubectl apply -f k8-Application/application-dev.yaml


Configuration
Key ConfigMaps

- environment-config: Basic settings
- service-api-config: Service endpoints
- demo-data-config: Demo user data
- gcp-settings: GCP features
- jwt-key: Authentication


Important Environment Variables

- ENABLE_TRACING: Toggle tracing
- ENABLE_METRICS: Toggle metrics
- LOCAL_ROUTING_NUM: Bank routing number
- PUB_KEY_PATH: JWT public key path

Troubleshooting
Common issues and solutions:

- Pod startup failures: Check JWT secret
- Image pull errors: Verify Docker Hub access
- Service connection issues: Check ConfigMaps
