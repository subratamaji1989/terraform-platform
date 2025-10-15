# 🚀 Terraform Platform Overview -- AWS

---

## 📑 Table of Contents

1. [Introduction](#introduction)
2. [Infrastructure Flow (GitOps IaC)](#infrastructure-flow-gitops-iac)
3. [Modules](#modules)
    - [Network Module](#network-module)
    - [VM Module](#vm-module)
    - [Storage Module](#storage-module)
    - [Load Balancer Module](#load-balancer-module)
4. [Compositions](#compositions)
5. [Schemas](#schemas)
6. [Tools](#tools)
7. [Pipelines](#pipelines)
8. [Usage](#usage)
9. [IAM Permissions](#iam-permissions)

---

## 🏁 Introduction

The Terraform Platform provides a set of reusable modules and compositions for managing AWS infrastructure using Terraform. This project aims to streamline the process of deploying and managing cloud resources, ensuring best practices and modularity.

---

## 🌊 Infrastructure Flow (GitOps IaC)

The infrastructure deployment utilizes a Code Repository for all declarative configuration, ensuring Git is the Single Source of Truth (SSOT).

| Step | Component        | Tool/Service                                | Description & DevSecOps Principle                                                                                                                                                           |
| :--- | :--------------- | :------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1.   | **Commit IaC**   | `infra-repo` Git (e.g., GitHub/CodeCommit)  | Developer commits Terraform code (for VPC, EKS, ALB) to a main branch via Pull Request (PR).                                                                                                |
| 2.   | **Validate IaC** | CI/CD Pipeline (GitHub Actions / CodeBuild) | **IaC Scanning (Shift-Left Security):** Runs `Checkov` to scan for misconfigurations (e.g., public S3 buckets, weak Security Groups) and `TFLint` for syntax validation.                      |
| 3.   | **Approval**     | PR Review (GitHub/CodeCommit)               | Requires a DevSecOps Architect and SRE approval to ensure security and operational best practices.                                                                                        |
| 4.   | **Apply IaC**    | CD Tool (Terraform/Terragrunt)              | Merged PR triggers the pipeline to run `terraform apply`. The EKS cluster, its Node Groups (or Fargate profiles), and supporting services (VPC, ALB) are provisioned.                        |
| 5.   | **Bootstrap GitOps** | Terraform / Helm                          | ArgoCD is installed into the new EKS cluster, and its configuration is pointed to the `app-manifests-repo`.                                                                             |

---

## 🛠️ Modules

-   ### Network Module

The Network module defines resources such as VPCs, subnets, and route tables. It allows for the creation and management of network infrastructure.

-   ### VM Module

The VM module is responsible for defining EC2 instances and EBS volumes. It provides a way to manage virtual machines in the AWS environment.

-   ### Storage Module

The Storage module defines resources for managing S3 buckets and lifecycle rules. It facilitates the storage and retrieval of data in the cloud.

-   ### Load Balancer Module

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

```

The `eval` command in the build spec ensures that a variable like `COMPOSITION_PATH` is resolved at runtime, correctly substituting `${CLOUD}` and `${STACK_NAME}` with their values.

---

## 📖 Usage

To use the Terraform Platform, clone the repository and follow the instructions in the respective module and composition README files. Ensure that you have the necessary AWS credentials and permissions to create and manage resources.
1.  **Centralized Buildspecs (The "Templates"):**
    -   Your `terraform-platform/aws/pipelines/buildspec.yml` and other `buildspec` files are your reusable templates. They contain the logic for installing tools, running scans, and executing Terraform commands.

2.  **Pipeline Definition in `app-ovr-infra` (The "Caller"):**
    -   You can define your pipeline using a tool like the AWS CDK or CloudFormation, or configure it via the console. The key is how you configure the CodeBuild project within your pipeline stages.
    -   This pipeline will live in or be associated with the `app-ovr-infra` repository, as it is specific to that application's deployment lifecycle.

**Example CodePipeline Stage Configuration (Conceptual):**

Here is how you would configure the "Validate" stage in your CodePipeline to call the "template" `buildspec.yml` from the platform repository.

-   **Action Provider:** `AWS CodeBuild`
-   **Input Artifacts:**
    -   `AppRepo` (from your `app-ovr-infra` source action)
    -   `PlatformRepo` (from your `terraform-platform` source action)
-   **Project Configuration:**
    -   **Buildspec Location:** Point to the buildspec file inside the `PlatformRepo` input artifact.
        -   `terraform-platform/aws/pipelines/buildspec.yml`
    -   **Environment Variables (The "Parameters"):** This is where you pass the application-specific details to the generic template.

        | Variable Name       | Value                                                | Description                                                              |
        | ------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------ |
        | `COMPOSITION_PATH`  | `terraform-platform/aws/infra-stack/vm-stack`        | Tells the template which infrastructure stack to build.                  |
        | `VARS_PATH`         | `app-ovr-infra/aws/dev/vars`                         | Tells the template where to find the YAML variables for this application.|
        | `SCHEMA_PATH`       | `terraform-platform/aws/schemas/vm.schema.json`      | Specifies the schema for validation.                                     |

By using this method, you maintain a clean separation of concerns:
-   **`terraform-platform`** owns the *how* (the build logic and templates).
-   **`app-ovr-infra`** owns the *what* (the pipeline definition and the specific parameters for the application).

This allows you to have many different application pipelines in different repositories all calling the same, centrally managed build templates, which is the core benefit of the pattern you described.
---

## 🔐 IAM Permissions

To run this Terraform platform securely, especially within a CI/CD pipeline, it's crucial to follow the principle of least privilege. The pipeline should use different IAM roles for different stages.

### `validate-role`

This role is used during the initial validation and security scanning stages. It requires **no AWS permissions** to access infrastructure resources.

-   **Permissions:**
    -   Read access to the source code repositories (e.g., `codecommit:GitPull`).
    -   Permissions to write logs (e.g., `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents`).

### `plan-role`

This role is used to generate a Terraform plan. It needs read-only access to the Terraform state but no permissions to modify resources.

-   **Permissions:**
    -   All permissions from `validate-role`.
    -   Read-only access to the Terraform state S3 bucket.
    -   Read-only access to the DynamoDB lock table.

**Example IAM Policy (`plan-policy.json`):**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::<YOUR_STATE_BUCKET_NAME>/path/to/terraform.tfstate"
        },
        {
            "Effect": "Allow",
            "Action": "dynamodb:GetItem",
            "Resource": "arn:aws:dynamodb:<REGION>:<ACCOUNT_ID>:table/<YOUR_LOCK_TABLE_NAME>"
        }
    ]
}
```

### `apply-role`

This is the most privileged role, used to apply changes to your infrastructure. It needs permissions to read/write the Terraform state and manage the specific AWS resources defined in your modules.

-   **Permissions:**
    -   All permissions from `plan-role`.
    -   Write access to the Terraform state S3 bucket and DynamoDB lock table.
    -   Permissions to create, modify, and delete the resources managed by your compositions (e.g., `ec2:*`, `eks:*`, `iam:CreateRole`, `ecr:CreateRepository`).

**Example IAM Policy (`apply-policy.json`):**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformStateAndLocking",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::<YOUR_STATE_BUCKET_NAME>/path/to/terraform.tfstate"
        },
        {
            "Sid": "TerraformLocking",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:<REGION>:<ACCOUNT_ID>:table/<YOUR_LOCK_TABLE_NAME>"
        },
        {
            "Sid": "EC2NetworkAndCompute",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:Create*",
                "ec2:Delete*",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:AttachInternetGateway",
                "ec2:DetachInternetGateway",
                "ec2:AssociateRouteTable",
                "ec2:DisassociateRouteTable",
                "ec2:AuthorizeSecurityGroup*",
                "ec2:RevokeSecurityGroup*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMRolesForEKS",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:List*",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PassRole",
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/*"
        },
        {
            "Sid": "EKSClusterManagement",
            "Effect": "Allow",
            "Action": [
                "eks:CreateCluster",
                "eks:DescribeCluster",
                "eks:DeleteCluster",
                "eks:TagResource",
                "eks:UntagResource"
            ],
            "Resource": "arn:aws:eks:<REGION>:<ACCOUNT_ID>:cluster/*"
        },
        {
            "Sid": "ECRRepositoryManagement",
            "Effect": "Allow",
            "Action": [
                "ecr:CreateRepository",
                "ecr:DeleteRepository",
                "ecr:DescribeRepositories",
                "ecr:TagResource",
                "ecr:ListTagsForResource",
                "ecr:DescribeImages"
            ],
            "Resource": "arn:aws:ecr:<REGION>:<ACCOUNT_ID>:repository/*"
        },
        {
            "Sid": "LoadBalancerManagement",
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Sid": "S3BucketManagement",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:PutBucketTagging"
            ],
            "Resource": "arn:aws:s3:::*"
        }
    ]
}

```
> **Note:** For production environments, it is highly recommended to scope the `Resource` ARNs to be as specific as possible rather than using `*`.
--- 

This README serves as a guide to understanding the structure and purpose of the Terraform Platform within the AWS infrastructure as code project.