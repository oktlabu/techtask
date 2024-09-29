---

> **Created by Gumarov Abu-Bakar**  
> *DevOps Engineer*

---

# CI/CD Pipeline for Terraform, Docker, and Azure

## Overview

This project outlines the CI/CD pipeline for deploying an API using Terraform to create Azure resources, Docker for building and pushing images, and Azure DevOps (ADO) for orchestration. The pipeline consists of 4 stages:

1. Install Terraform and Docker on the Agent Pool, and copy project files.
2. Run Terraform to provision a Resource Group, Key Vault, and Azure Container Registry (ACR).
3. Build and push the Docker image for the API to the ACR.
4. Create additional resources after the image is available.

## Prerequisites

- Azure App Registration with RBAC access Subscription or Resource groups.
- Azure Subscription
- Azure DevOps (ADO) organization
- Docker installed on the laptop
- Terraform installed on the laptop

## Manual actions

- Created variable group in Pipeline Library Tab
- Created service connection for Azure Container Registry in ADO.

## API URLs

- **Data API:** `http://public_ip/api/data`
- **Root URL:** `http://public_ip/`

## Environment Variables

Ensure the following environment variables are set for authentication with Azure:

```bash
$env:ARM_CLIENT_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$env:ARM_CLIENT_SECRET="xxxxxxxxxxxxxxxxxxxxxxxx"
$env:ARM_SUBSCRIPTION_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
$env:ARM_TENANT_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"



