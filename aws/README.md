# 🚀 Terraform Platform Overview --AWS

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

The Terraform Platform provides a set of reusable modules and compositions for managing AWS infrastructure using Terraform. This project aims to streamline the process of deploying and managing cloud resources, ensuring best practices and modularity.

---

## 🛠️ Modules

### Network Module

The Network module defines resources such as VPCs, subnets, and route tables. It allows for the creation and management of network infrastructure.

### VM Module

The VM module is responsible for defining EC2 instances and EBS volumes. It provides a way to manage virtual machines in the AWS environment.

### Storage Module

The Storage module defines resources for managing S3 buckets and lifecycle rules. It facilitates the storage and retrieval of data in the cloud.

### Load Balancer Module

The Load Balancer module manages resources for Application Load Balancers (ALBs) or Network Load Balancers (NLBs). It ensures high availability and scalability for applications.

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

## 🔄 Pipelines

The pipelines directory contains build specifications for the CI/CD pipeline, defining the steps for validation, planning, applying, and post-validation of Terraform configurations.

### Key Features

-   **Dynamic Configuration**: The pipeline's behavior is controlled by a `pipeline-vars.yml` file. This file defines environment variables (`CLOUD`, `STACK_NAME`, `TF_VERSION`, etc.) that are loaded at runtime, allowing the same `buildspec.yml` to be used for multiple environments and stacks.
-   **Staged Execution**: The pipeline can be run in different modes by setting the `PIPELINE_STAGE` environment variable. This allows for granular control over the workflow. Supported stages are:
    -   `VALIDATE`: Performs schema validation, security scans, and a dry-run `terraform plan`.
    -   `PLAN`: Initializes the backend and generates a production `terraform plan`.
    -   `APPLY`: Applies a previously generated plan file.
    -   `POST_VALIDATE`: Runs checks after a successful deployment.
    -   `ALL` (default): Runs all stages sequentially.
-   **Automated Tooling**: The `install` phase automatically downloads and caches specific versions of `terraform`, `tflint`, `tfsec`, and other dependencies, ensuring a consistent and fast execution environment.
-   **Integrated Security (DevSecOps)**: During the `VALIDATE` stage, the pipeline automatically runs `tflint` and `tfsec` to scan the Terraform code for misconfigurations and security vulnerabilities.
-   **Schema Validation**: Before running Terraform, the pipeline uses `ajv-cli` to validate the `.yml` variable files against their corresponding JSON schemas located in the `schemas` directory. This prevents invalid configurations from ever reaching the plan stage.

### Build Phases Explained

1.  **`install` Phase**:
    -   Sets up a local cache directory (`.local/bin`) for tools.
    -   Loads all variables from the `pipeline-vars.yml` file.
    -   Installs pinned versions of Terraform, `tflint`, `tfsec`, `yq`, and `ajv-cli`.
    -   Verifies that all tools were installed correctly.

2.  **`pre_build` Phase**:
    -   Re-exports the environment variables loaded in the `install` phase, as CodeBuild uses a new shell for each phase.

3.  **`build` Phase**:
    -   **Path Resolution**: Dynamically constructs the path to the correct Terraform composition based on the `CLOUD` and `STACK_NAME` variables.
    -   **Variable Merging**: Uses the `tools/yaml2tfvars.py` script to merge all relevant `.yml` files into a single `all.tfvars.json` file for Terraform.
    -   **Staged Execution**: Executes the `VALIDATE`, `PLAN`, `APPLY`, and `POST_VALIDATE` logic based on the `PIPELINE_STAGE` variable.

### How Variables are Loaded

The `buildspec.yml` uses `yq` to parse the `pipeline-vars.yml` file and `eval` to export its keys as environment variables. This happens in both the `install` and `pre_build` phases to ensure the variables are available throughout the build.

An example `pipeline-vars.yml` might look like this:

```yaml
pipeline-parameters:
  # -- Infrastructure Definition --
  APP: "app-ovr-infra"
  CLOUD: "aws"
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

To use the Terraform Platform, clone the repository and follow the instructions in the respective module and composition README files. Ensure that you have the necessary AWS credentials and permissions to create and manage resources.

1.  **Define Infrastructure**: Create or select a `composition` that orchestrates the required modules (e.g., `vm-stack`).
2.  **Configure Variables**: Add or modify the YAML variable files in the `vars` directory for your specific environment (e.g., `vars/dev/main.yml`). These variables will be passed to the modules.
3.  **(Optional) Create a Schema**: To ensure data integrity, create a JSON schema in the `schemas` directory that validates your new YAML variables.
4.  **Update Pipeline Configuration**: Modify the `pipeline-vars.yml` file to point to the correct `CLOUD`, `ENVIRONMENT`, and `STACK_NAME`. This tells the CI/CD pipeline what to build and deploy.
5.  **Commit and Push**: Commit your changes to a feature branch and create a pull request.
6.  **Automated Execution**: The CI/CD pipeline will automatically trigger, running the `VALIDATE` and `PLAN` stages. A reviewer can then approve the plan, and upon merging to the main branch, the `APPLY` stage will execute to deploy the changes.

--- 

This README serves as a guide to understanding the structure and purpose of the Terraform Platform within the AWS infrastructure as code project.