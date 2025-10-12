# 🚀 Terraform Platform for Azure

---

## 📑 Table of Contents

1. [Introduction](#introduction)
2. [Modules](#modules)
    - [Network Module](#network-module)
    - [VM Module](#vm-module)
    - [Storage Module](#storage-module)
    - [Load Balancer Module](#load-balancer-module)
3. [Compositions](#compositions)
4. [Schemas](#schemas)
5. [Tools](#tools)
6. [Pipelines](#pipelines)
7. [Usage](#usage)

---

## 🏁 Introduction

This Terraform Platform provides a set of reusable modules and compositions specifically for managing **Azure** infrastructure. This project aims to streamline the process of deploying and managing cloud resources, ensuring best practices and modularity.

---

## 🛠️ Modules

### 🌐 Network Module

The Network module establishes the foundational networking infrastructure for an environment. It is designed to be modular and configurable for different network topologies.
*   **Key Resources**: Virtual Networks (VNets), Subnets, Route Tables, Network Security Groups (NSGs), Public IP Addresses.
*   **Features**: Supports multi-region deployments, configurable address spaces, and network security rules.

### 💻 VM Module

The VM module is responsible for provisioning and configuring Azure Virtual Machines. It abstracts away the complexity of instance setup, allowing for repeatable server deployments.
*   **Key Resources**: Virtual Machines (VMs), Managed Disks, Network Interfaces (NICs), Custom Script Extensions for bootstrapping.
*   **Features**: Configurable VM sizes, OS images, data disk management, and integration with Azure Active Directory for secure access.

### 🗄️ Storage Module

The Storage module provides a standardized way to create and manage Azure Storage Accounts for various purposes, such as application data, logs, or artifacts.
*   **Key Resources**: Storage Accounts, Blob Containers, File Shares, Access Policies, Lifecycle Management.
*   **Features**: Secure-by-default configurations, automated cost optimization via lifecycle rules, and support for different storage tiers.

### ⚖️ Load Balancer Module

The Load Balancer module manages traffic distribution to ensure high availability and scalability for applications.
*   **Key Resources**: Azure Application Gateways, Azure Load Balancers, Public IP Addresses, Backend Pools, Health Probes.
*   **Features**: Support for different listener types (HTTP/HTTPS), integration with Azure Key Vault for SSL/TLS certificates, and configurable health check parameters.

---

## 🏗️ Compositions

Compositions are the top-level infrastructure definitions that assemble reusable modules into a complete, deployable stack (e.g., a `vm-stack` that combines the `network`, `vm`, and `load-balancer` modules).
*   **Why it's needed**: Compositions allow you to define a complete environment by orchestrating modules, promoting reuse and preventing configuration drift. They represent the "what to build," while modules represent the "how to build it."
*   **Usage**: A developer defines a new stack by creating a directory under `compositions/`. Inside, a `main.tf` file calls the necessary modules and passes variables to them. The CI/CD pipeline targets a specific composition using the `COMPOSITION_PATH` variable defined in `pipeline-vars.yml`.

---

## 📜 Schemas

The `schemas` directory contains JSON Schema files used to validate the structure and data types of your YAML variable files.
*   **Why it's needed**: Schemas enforce a contract for your configuration, catching errors like typos, incorrect data types, or missing required fields *before* Terraform runs. This "shift-left" approach to validation prevents simple configuration mistakes from causing a pipeline failure during the `plan` or `apply` stage.
*   **Usage**: For a given YAML file (e.g., `vm-stack.yml`), you create a corresponding `vm-stack.schema.json` file. The `buildspec.yml` automatically uses the `ajv-cli` tool during the `VALIDATE` stage to check that the YAML file conforms to its schema.
*   **Reference**: This is implemented in the `validate_yaml_files` function within the `build` phase of the `buildspec.yml`.

---

## 🛠️ Tools

This directory contains helper scripts that provide "glue" logic for the CI/CD pipeline.
*   **`yaml2tfvars.py`**: A Python script that merges a directory of YAML variable files into a single `all.tfvars.json` file.
*   **Why it's needed**: This tool bridges the gap between human-friendly YAML (which supports comments and a cleaner structure) and Terraform's required JSON format for variable files (`-var-file`). It allows developers to manage configuration in a more readable format.
*   **Usage**: The script is called automatically by the `buildspec.yml` during the `build` phase before any `terraform` commands are run.

---

## 🔄 CI/CD with Azure Pipelines

The `pipelines` directory contains the YAML definition (`azure-pipelines.yml`) for the CI/CD pipeline, designed to run in **Azure Pipelines**. This pipeline is a flexible, multi-stage engine for validating and deploying Terraform infrastructure on Azure.

### Key Features

-   **Dynamic Configuration**: The pipeline's behavior is controlled by a `pipeline-vars.yml` file and **Variable Groups** in Azure DevOps. This allows the same pipeline definition to be used for multiple environments and stacks.
-   **Staged Execution**: The pipeline is broken into distinct stages (`Validate`, `Plan`, `Apply`) for granular control and manual approvals between stages.
    -   `VALIDATE`: Performs schema validation, security scans, and a dry-run `terraform plan`.
    -   `PLAN`: Initializes the backend and generates a production `terraform plan`.
    -   `APPLY`: Applies a previously generated plan file.
-   **Automated Tooling**: A setup step automatically downloads and caches specific versions of `terraform`, `tflint`, `tfsec`, and other dependencies, ensuring a consistent and fast execution environment.
-   **Integrated Security (DevSecOps)**: During the `VALIDATE` stage, the pipeline automatically runs `tflint` and `tfsec` to scan the Terraform code for misconfigurations and security vulnerabilities.
-   **Schema Validation**: Before running Terraform, the pipeline uses `ajv-cli` to validate the `.yml` variable files against their corresponding JSON schemas. This "shift-left" approach prevents invalid configurations from ever reaching the plan stage.

### Pipeline Stages Explained

1.  **Validate Stage**:
    -   Runs on every pull request.
    -   Installs tools, validates YAML schemas, runs `terraform init`, `terraform validate`, and security scans.
    -   This stage ensures code quality and security before it can be merged.

2.  **Plan Stage**:
    -   Runs after a pull request is merged to the main branch.
    -   Initializes Terraform with the Azure backend.
    -   Generates a `terraform plan` and publishes the plan file as a pipeline artifact.
    -   This stage often includes a manual approval step before proceeding to `Apply`.

3.  **Apply Stage**:
    -   Runs after the `Plan` stage is approved.
    -   Downloads the plan artifact from the `Plan` stage.
    -   Executes `terraform apply` using the plan file to deploy the infrastructure to Azure.

### How Variables are Loaded

In Azure Pipelines, variables are managed through a combination of `pipeline-vars.yml` and **Variable Groups**.

1.  **Variable Groups**: Secure values like the Azure Service Principal credentials (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, etc.) are stored in a linked Variable Group in Azure DevOps.
2.  **YAML Parsing**: The pipeline uses a script step with `yq` to parse the `pipeline-vars.yml` file and export its keys as pipeline variables. This allows for dynamic configuration based on the committed file.

An example `pipeline-vars.yml` might look like this:

```yaml
pipeline-parameters:
  # -- Infrastructure Definition --
  APP: "app-ovr-infra"
  CLOUD: "azure"
  ENVIRONMENT: "dev"
  STACK_NAME: "vm-stack"

  # -- Dynamic Path Configuration --
  COMPOSITION_PATH: "${CLOUD}/infra-stack/${STACK_NAME}"
  SCHEMAS_DIR_PATH: "${CLOUD}/schemas"
  VARS_PATH: "${APP}/${CLOUD}/${ENVIRONMENT}/vars"
  BACKEND_CONFIG_PATH: "${APP}/${CLOUD}/${ENVIRONMENT}/backend.tf"
```

The `eval` command in the build spec ensures that a variable like `COMPOSITION_PATH` is resolved at runtime, correctly substituting `${CLOUD}` and `${STACK_NAME}` with their values.

---

## 📖 Usage

To use the Terraform Platform for Azure, clone the repository and follow the instructions below. Ensure that you have an Azure Service Principal with the necessary permissions to create and manage resources in your subscription.

1.  **Define Infrastructure**: Create or select a `composition` that orchestrates the required modules (e.g., `vm-stack`).
2.  **Configure Variables**: Add or modify the YAML variable files in the `vars` directory for your specific environment (e.g., `vars/dev/main.yml`). These variables will be passed to the modules.
3.  **(Optional) Create a Schema**: To ensure data integrity, create a JSON schema in the `schemas` directory that validates your new YAML variables.
4.  **Update Pipeline Configuration**: Modify the `pipeline-vars.yml` file to point to the correct `CLOUD`, `ENVIRONMENT`, and `STACK_NAME`. This tells the CI/CD pipeline what to build and deploy.
5.  **Commit and Push**: Commit your changes to a feature branch and create a pull request.
6.  **Automated Execution**: The CI/CD pipeline will automatically trigger, running the `VALIDATE` and `PLAN` stages. A reviewer can then approve the plan, and upon merging to the main branch, the `APPLY` stage will execute to deploy the changes.

--- 

This README serves as a guide to understanding the structure and purpose of the Terraform Platform within the **Azure** infrastructure as code project.