* Produce Terratest sample code for CI integration tests.
# 🚀 Terraform Platform for Azure — Enhanced DevSecOps Guide

> **Target audience:** Platform Engineers, DevOps Engineers, Security Engineers, SREs
>
> **Purpose:** A detailed, executable, and audit-ready platform playbook. This document expands on architecture, standards, CI/CD, security controls, testing, and operational runbooks so teams can safely and repeatedly deploy Azure infrastructure as code.

---

## 📜 Table of Contents

1.  **Executive Summary** (Objectives & Scope)
2.  **Platform Design Principles**
3.  **Two-Repository Model** (Repo Contracts)
4.  **Module Design Standards** (Structure, I/O, Naming, Testing)
5.  **Compositions & Patterns** (Topologies & Wiring)
6.  **Schemas & Validation** (JSON Schema, AJV)
7.  **CI/CD Engine (Azure DevOps)** (Pipeline Design & Secure Auth)
8.  **Security & Governance** (RBAC, WIF/OIDC, Key Vault)
9.  **Terraform State Management** (Backend Hardening)
10. **Policy-as-Code** (Runtime Guardrails)
11. **Testing Strategy** (Unit, Integration, Policy, E2E)
12. **Observability & Auditing**
13. **Developer Experience (DX)** (Self-Service)
14. **Operational Playbooks** (Restore, Rollbacks, Drift)
15. **Governance & Onboarding**
16. **Appendix** (Snippets & Templates)

---

## 1. Executive Summary

This guide codifies a mature, secure, and repeatable Terraform platform for Azure. It standardizes how modules are authored, validated, tested, versioned, released, and consumed by application teams. It enforces security and compliance through shift-left validation (schemas, linting, static scanning), policy-as-code, secretless authentication, and runtime guardrails.

### Key Outcomes

*   ✅ **Safe Self-Service:** Empower application teams to provision infrastructure independently.
*   🛡️ **Centralized Security:** Enforce compliance and security controls from a single point.
*   🔄 **Repeatable CI/CD:** Deliver infrastructure changes with a full audit trail and minimized blast radius.
*   🔍 **Observable & Recoverable:** Ensure the entire infrastructure lifecycle is observable and recoverable.

---

## 2. Platform Design Principles

*   🔐 **Least Privilege by Default**: Every identity, role, and permission is scoped to the smallest necessary boundary.
*   🏗️ **Immutable Infrastructure**: All changes are made via code, reviewed, and deployed through automation. No manual "click-ops".
*   📚 **Single Source of Truth**: Git is the definitive source for all infrastructure definitions, enforced with signed commits and PR reviews.
*   ⬅️ **Shift-Left Security**: Validate schemas, run static analysis, and apply policy checks *before* code is merged.
*   🧩 **Composability & Reusability**: Build with small, focused modules that are wired together by larger compositions.
*   🗺️ **Discoverability**: Document all modules and compositions with examples, inputs, outputs, and required permissions.
*   📊 **Observability & Auditability**: Capture telemetry, logs, and state audit trails for every deployment.

---

## 3. Two-Repository Model — Extended

The platform is built on a decoupled, two-repository model to enforce separation of concerns between the platform itself and the applications that consume it.

### `terraform-platform` (The Platform Repo)

*   **Owner**: Platform Engineering / Cloud CoE
*   **Contains**:
    *   `modules/`: Reusable, versioned, and tested building blocks.
    *   `compositions/`: Opinionated stacks that combine modules into deployable solutions.
    *   `schemas/`: JSON Schemas for validating all supported composition inputs.
    *   `pipelines/`: Reusable Azure DevOps pipeline templates.
    *   `examples/`: Reference implementations for `app-ovr-infra`.
    *   `docs/`: Auto-generated documentation for modules.
    *   `tests/`: Unit and integration tests for all modules.
*   **Versioning**: Platform changes are released via Git tags (e.g., `v1.2.0`) with a corresponding `CHANGELOG.md`.

### `app-ovr-infra` (The Application Infra Repo)

*   **Owner**: Application Team
*   **Contains**:
    *   `vars/`: YAML variable files organized by environment (`dev`, `prod`).
    *   `backend.tf`: Backend configuration pointing to the application's unique state file.
    *   `pipeline-vars.yml`: Parameters consumed by the shared CI/CD pipeline.
*   **Constraints**:
    *   Must reference approved module versions from `terraform-platform` (via a private registry or Git tags).
    *   No raw Terraform resources or manual `az cli` commands are permitted without an explicit exception.

### Contract Requirements (Enforced by CI)

*   The `app-ovr-infra` repo **must** include a `pipeline-vars.yml`.
*   All `vars/*.yml` files **must** be validated against a corresponding schema from the `terraform-platform` repo.

---

## 4. Module Design Standards (Detailed)

Each module is a small, focused unit of work. Treat modules as internal packages with a public API (`variables.tf`, `outputs.tf`) and a private implementation (`main.tf`).

**Module Layout**:
```plaintext
modules/<module-name>/
├── README.md          # Purpose, example usage, required permissions
├── main.tf            # Core resource blocks
├── variables.tf       # Documented input variables with types and validation
├── outputs.tf         # Documented outputs for wiring
├── versions.tf        # Provider and Terraform version constraints
└── examples/
    └── basic/         # A minimal, working example
```

**Input Standards (`variables.tf`)**:
*   Use explicit types (`string`, `number`, `list(...)`) and `validation` blocks.
*   Avoid generic `object` types; prefer typed objects with clear `description`.
*   Provide a `default` only when it's safe; otherwise, make variables required.
*   Mark sensitive inputs with `sensitive = true`.

**Output Standards (`outputs.tf`)**:
*   Output resource IDs, not raw connection strings or secrets.
*   Mark sensitive outputs with `sensitive = true`.

**Naming & Tagging**:
*   Enforce a consistent naming convention via module locals (e.g., `{org}-{app}-{env}-{component}-{region}`).
*   Modules **must** attach a standard set of tags: `owner`, `environment`, `cost_center`, `created_by_pipeline`, `module_version`.

**Permissions**:
*   The module's `README.md` must document the minimal RBAC permissions required (e.g., `Microsoft.Network/virtualNetworks/write`).

**Versioning & Releases**:
*   Follow Semantic Versioning (`MAJOR.MINOR.PATCH`).
*   Publish modules to a private Terraform registry or reference them by an immutable Git tag.

**Testing**:
*   **Integration Tests**: Deploy to a short-lived sandbox subscription using Terratest or a similar framework.
*   **Security Scans**: Run `tfsec` and `checkov` on all module code.

---

## 5. Compositions & Patterns

**Compositions** are opinionated, production-ready stacks that wire modules together to form a complete solution.

**Common Patterns**:
*   `infra-stack`: `network` + `subnet` + `nsg` + `vm` + `log-analytics` + `aks` + `managed-identity` + `key-vault` + `ingress-controller` + `app-service-plan` + `app-service`

**Wiring Rules**:
*   Use explicit module outputs for wiring. Never reference resource addresses directly across modules.
*   Keep composition inputs minimal. Prefer composition-level defaults that can be overridden by `vars/` files.

---

## 6. Schemas & Validation

**Goal**: Prevent typos, invalid enums, prohibited VM sizes, and missing tags. Fail fast during PR validation.

**Implementation**:
*   JSON Schema files are stored in `terraform-platform/schemas/`.
*   A CI pipeline step uses `ajv-cli` to validate every `vars/*.yml` file against its corresponding schema.

**Example**:
*   **`app-ovr-infra/vars/vm.yml`** (Developer Input)
    ```yaml
    vms:
      - name: "web-server-01"
        size: "Standard_B2s" # Allowed size
    ```
*   **`terraform-platform/schemas/vm.schema.json`** (Validation Rule)
    ```json
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "properties": {
        "vms": {
          "type": "array",
          "items": {
            "properties": {
              "size": {
                "type": "string",
                "enum": ["Standard_B1s", "Standard_B2s", "Standard_D2s_v3"]
              }
            },
            "required": ["name", "size"]
          }
        }
      }
    }
    ```

---

## 7. CI/CD Engine — Azure DevOps (Detailed Pipeline)

The platform provides a reusable Azure Pipelines template that each `app-ovr-infra` repository references.

**Pipeline Stages**:

1.  **`Validate-PR`** (Runs on Pull Requests)
    *   **Install Tools**: `terraform`, `tflint`, `tfsec`, `ajv-cli`, `infracost`.
    *   **Schema Validation**: Runs `ajv-cli` against `vars/` files.
    *   **Static Analysis**: `terraform fmt -check`, `terraform validate`, `tflint`, `tfsec`.
    *   **Dry Run Plan**: Runs `terraform init -backend=false` and `terraform plan` to validate logic.
    *   **Publish Results**: Attaches validation results and security reports to the PR.

2.  **`Plan`** (Runs on merge to `main`)
    *   **Authenticate**: Acquires credentials via Workload Identity Federation.
    *   **Initialize Backend**: Runs `terraform init` with the remote state backend.
    *   **Generate Plan**: Runs `terraform plan -out=tfplan` and `infracost` to estimate cost changes.
    *   **Publish Artifacts**: Publishes the `tfplan` file and cost report for approval.

3.  **`Approval`** (Manual gate for production)
    *   Uses Azure DevOps `Approvals and checks` to require sign-off.
    *   Approvers review the plan summary, security report, and cost delta.

4.  **`Apply`** (Runs after approval)
    *   **Authenticate & Download**: Acquires credentials and downloads the `tfplan` artifact.
    *   **Execute**: Runs `terraform apply -auto-approve tfplan`.
    *   **Post-Deploy**: Runs automated smoke tests to verify deployment health.

**Pipeline Security**:
*   **Authentication**: Use **Workload Identity Federation (OIDC)** to avoid storing client secrets.
*   **Secrets**: Use Azure Key Vault-backed Variable Groups for any necessary secrets.
*   **Agents**: Use Microsoft-hosted agents or hardened, ephemeral self-hosted agents.

---

## 7.1 CI/CD Setup: From Authentication to Pipeline

This section provides a step-by-step guide for setting up the necessary authentication and configuring the Azure DevOps pipeline.

### Step 1: Create the Pipeline's Identity (App Registration & Service Principal)

The pipeline needs an identity in Microsoft Entra ID to interact with your Azure subscription. This is called a Service Principal.

1.  **Log in to Azure CLI**:
    ```bash
    az login
    ```

2.  **Set your Subscription**:
    ```bash
    az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
    ```

3.  **Create the App Registration and Service Principal**:
    Give it a descriptive name, like `sp-tf-platform-prod`.
    ```bash
    # Create the App Registration
    APP_ID=$(az ad app create --display-name "sp-tf-platform-prod" --query appId -o tsv)

    # Create the Service Principal for the App
    SP_OBJECT_ID=$(az ad sp create --id $APP_ID --query id -o tsv)

    echo "Service Principal App ID (Client ID): $APP_ID"
    ```

4.  **Assign Permissions**:
    Grant the Service Principal the `Contributor` role on the scope it needs to manage (e.g., a specific Resource Group). Using a Resource Group scope is more secure than Subscription scope.
    ```bash
    az role assignment create \
      --assignee $APP_ID \
      --role "Contributor" \
      --scope "/subscriptions/<YOUR_SUBSCRIPTION_ID>/resourceGroups/<YOUR_TARGET_RESOURCE_GROUP>"
    ```

### Step 2: Configure the Service Connection in Azure DevOps (WIF/OIDC)

Next, you'll create a **Service Connection** in Azure DevOps. This allows your pipeline to authenticate as the Service Principal you just created. We will use the recommended **Workload Identity Federation** method, which is secret-less.

1.  **Create the Federated Credential**:
    This command tells Azure to trust tokens coming from your specific Azure DevOps pipeline.
    ```bash
    # Get your ADO organization name and project name
    ADO_ORG_NAME="YourADOOrganization"
    ADO_PROJECT_NAME="YourADOProject"
    REPO_NAME="app-ovr-infra" # The name of your application infra repo

    # Create the trust relationship
    az ad app federated-credential create \
      --id $APP_ID \
      --parameters '{"name":"ado-federation-main","issuer":"https://vstoken.azure.com/<ADO_ORG_ID>","subject":"repo:'"$ADO_ORG_NAME/$ADO_PROJECT_NAME/$REPO_NAME"':refs/heads/main","audiences":["api://AzureADTokenExchange"]}'
    ```
    > **Note**: The `subject` is highly specific. This example trusts tokens only from the `main` branch of the `app-ovr-infra` repository.

2.  **Create the Service Connection in the UI**:
    *   Navigate to your Azure DevOps project: **Project Settings** > **Service connections** (under Pipelines).
    *   Click **New service connection**.
    *   Select **Azure Resource Manager**.
    *   For the authentication method, choose **Workload Identity federation (automatic)**.
    *   Follow the prompts. Azure DevOps will detect the App Registration you created. Select it to complete the connection.
    *   Give the connection a memorable name, like `Azure-Prod-Federated`. You will use this name in your pipeline YAML.

### Step 3: Create and Run the Pipeline

Finally, create the pipeline in Azure DevOps that will consume your `app-ovr-infra` repository and use the Service Connection.

1.  **Navigate to Pipelines**: In your ADO project, go to the **Pipelines** section and click **New pipeline**.
2.  **Select Repository**: Choose the location of your `app-ovr-infra` repository (e.g., Azure Repos Git or GitHub).
3.  **Configure**: Select **Existing Azure Pipelines YAML file**.
4.  **Path**: Point it to the `azure-pipelines.yml` file within your `app-ovr-infra` repository.

Your `app-ovr-infra/azure-pipelines.yml` should look similar to the one in the Appendix, which uses a template from the `terraform-platform` repo. The key is passing the name of the service connection you created:

```yaml
# In app-ovr-infra/azure-pipelines.yml

...
stages:
- stage: Validate_and_Plan
  displayName: 'Validate and Plan'
  jobs:
  - template: pipelines/templates/terraform-deploy.yml@platform # Reference the template
    parameters:
      environment: 'dev'
      stack_name: 'infra-stack'
      # This is the crucial link to your Service Connection
      ado_service_connection: 'Azure-Dev-Federated'
```

Once you save and run the pipeline, it will use the `Azure-Dev-Federated` service connection to authenticate with Azure via WIF/OIDC and execute the Terraform commands defined in the template.

---

## 8. Security & Governance Model (very detailed)

### 8.1 Authentication & Workload Identity Federation (WIF/OIDC)

This is the **recommended** secret-less authentication method.

**Setup**:
1.  Create an App Registration and Service Principal in Microsoft Entra ID.
2.  Create a Federated Credential that maps the Azure DevOps pipeline (by org, project, repo, and branch) to the App Registration.
3.  Configure an Azure DevOps Service Connection to use the federated credential.

**Sample `az cli` command**:
```bash
# This command establishes trust between Entra ID and a specific ADO pipeline branch
az ad app federated-credential create \
  --id <APP_ID> \
  --parameters '{"name":"ado-federation-main","issuer":"https://vstoken.azure.com/<ADO_ORG_ID>","subject":"repo:<ADO_ORG_NAME>/<PROJECT_NAME>/<REPO_NAME>:refs/heads/main","audiences":["api://AzureADTokenExchange"]}'
```
> **Note**: The exact `subject` format may vary. Always follow the latest Azure DevOps documentation.

### 8.2 RBAC & Least Privilege

*   Assign roles at the most granular scope possible (e.g., Resource Group, not Subscription).
*   Create custom roles with only the required actions instead of using the built-in `Contributor` role.
*   Document the roles and rationale for elevated privileges required by each composition.

### 8.3 Key Vault & Secrets

*   Modules should create Key Vaults with `soft-delete` and `purge-protection` enabled by default.
*   Applications should use a **Managed Identity** to access secrets from Key Vault at runtime.
*   Reference secrets in App Services or other PaaS offerings directly, avoiding injection at deploy time.

**Example (App Service setting)**:
```terraform
resource "azurerm_linux_web_app" "main" {
  # ...
  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    # This special syntax tells the App Service to fetch the secret at runtime
    "DB_PASSWORD" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_password.id})"
  }
}
```

---

## 9. Terraform State Management & Backend Hardening

*   **Storage**: Use an Azure Storage Account with a dedicated container.
*   **Security**:
    *   Enable `versioning` and `blob soft delete` to protect against accidental deletion.
    *   Restrict network access using a `private endpoint`.
    *   Use a Managed Identity (via WIF) for pipeline access instead of storage account keys.
*   **Isolation**:
    *   Each environment and stack **must** have a unique `key` in the backend (e.g., `app-ovr-infra/dev/infra-stack.tfstate`).
    *   Use separate storage accounts for `prod` vs. `non-prod` for maximum blast radius reduction.
*   **Locking**: The `azurerm` backend handles state locking automatically. Ensure pipelines can handle lock contention gracefully.

---

## 10. Policy-as-Code & Runtime Guardrails

**Enforcement Layers**:
*   **Pre-Merge (Static)**: Linting (`tflint`), schema validation (`ajv`), and static analysis (`tfsec`, `checkov`).
*   **Pre-Apply (Dynamic)**: Policy checks against the plan file using Open Policy Agent (`OPA`/`Conftest`).
*   **Runtime (Cloud)**: **Azure Policy** and Initiative assignments to block non-compliant resource creation at the source.

**Example Check**: Fail the pipeline if a resource is being created with a public IP in a production environment.

---

## 11. Testing Strategy

*   **Unit Testing**: Static checks, `terraform validate`, and local plan file analysis.
*   **Integration Testing**: Use **Terratest** (Go) to spin up a short-lived environment in a sandbox subscription, validate its resources, and tear it down.
*   **Policy Testing**: Maintain a test suite that runs policies against sample "good" and "bad" plan files to assert expected outcomes.
*   **Security Testing**: Integrate `tfsec`, `checkov`, and `tflint` with custom rulesets into the `Validate-PR` stage.
*   **Cost Testing**: Run `infracost` in the `Plan` stage and fail the build if the cost delta exceeds a configurable threshold.

---

## 12. Observability, Audit & Incident Response

*   **Telemetry**: Send platform pipeline logs to a central Log Analytics Workspace.
*   **Diagnostics**: Enable `Activity Logs` and `Diagnostic Settings` on all management resources (storage account, key vault, etc.).
*   **Alerting**: Configure alerts for critical policy violations, failed `apply` stages, or unexpected infrastructure drift.
*   **Incident Runbooks**: Maintain documented steps for handling plan/apply failures, state corruption, and rollbacks.

---

## 13. Developer Experience (DX) & Self-service

*   **CLI Helpers**: Provide a `scripts/bootstrap.sh` script to set up a local environment (install tools, log in, etc.).
*   **Templates**: Offer a skeleton `app-ovr-infra` repository containing the required file structure (`vars/`, `backend.tf`, etc.).
*   **Documentation**: Auto-generate module documentation (inputs/outputs) with `terraform-docs` on each release and publish to an internal catalog.

---

## 14. Operational Playbooks

### 14.1 Failed Apply / Rollback
1.  **Investigate**: Do not re-run `terraform apply`. Analyze pipeline logs and the failed plan.
2.  **Remediate**: If partial resources were deployed, use `terraform state rm` to remove them from state or run `terraform destroy` in a controlled manner.
3.  **Rollback**: To roll back, revert the Git commit and run a new plan/apply cycle to remove the unwanted resources.

### 14.2 State Corruption Recovery
1.  **Restore**: Use blob versioning and soft-delete to retrieve the last known good state file.
2.  **Verify**: Restore the `.tfstate` file to the backend container and run `terraform plan` to validate the recovery.

### 14.3 Drift Detection & Remediation
1.  **Detect**: Use scheduled pipelines that run `terraform plan` and alert on any non-empty plan for production resources.
2.  **Remediate**: For unauthorized drift, create a PR to bring the code back in line with the plan. For authorized emergency changes, update the code to match reality and document the change.

---

## 15. Governance Checklist & Onboarding

**Checklist for onboarding a new application team**:
*   [ ] Create `app-ovr-infra` repository from the official template.
*   [ ] Assign owners and a `cost_center` tag.
*   [ ] Configure `backend.tf` with a unique state key for each environment.
*   [ ] Create the Azure DevOps pipeline and connect it to the federated service connection.
*   [ ] Run a sample `Validate-PR` and fix any schema or policy violations.
*   [ ] Publish team-specific runbooks and SLOs.

---

## 16. Appendix — Snippets & Templates

### Azure Storage Backend (`backend.tf`)
```terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-prod"
    storage_account_name = "tfstateacmeprod"
    container_name       = "tfstate"
    key                  = "app-ovr-infra/prod/infra-stack.tfstate" # Unique key per env/stack
  }
}
```

### Minimal `azure-pipelines.yml` Reference
```yaml
# In app-ovr-infra/azure-pipelines.yml

trigger:
  branches:
    include:
    - main

resources:
  repositories:
  - repository: platform # Alias for the platform repo
    type: github
    name: YourOrg/terraform-platform
    ref: main # Or a specific tag/release

stages:
- stage: Validate_and_Plan
  displayName: 'Validate and Plan'
  jobs:
  - template: pipelines/templates/terraform-deploy.yml@platform # Call the template
    parameters:
      environment: 'dev'
      stack_name: 'infra-stack'
      ado_service_connection: 'Azure-Dev-Federated'
```

---
