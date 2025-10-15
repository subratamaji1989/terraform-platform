#!/bin/bash
set -euo pipefail

#
# This script performs comprehensive validation for the Terraform configuration.
# It is intended to be run from an Azure DevOps pipeline.
#

# --- Helper Functions ---

# Validates all YAML files in a given directory against their corresponding JSON schemas.
validate_yaml_files() {
  local vars_dir="$1"; local schemas_dir="$2"
  echo "--> Validating YAML files in '${vars_dir}'..."
  if [ ! -d "$vars_dir" ]; then echo "--> WARNING: Variables directory '$vars_dir' not found." && return; fi
  find "$vars_dir" -name "*.yaml" -o -name "*.yml" | while read -r yaml_file; do
      local filename=$(basename "${yaml_file}")
      local schema_name="${filename%.*}.schema.json"
      local schema_file="${schemas_dir}/${schema_name}"
      [ -f "$schema_file" ] && ajv validate -s "$schema_file" -d "$yaml_file" || echo "--> INFO: No schema for '${filename}'."
  done
}

# --- Main Execution ---

echo "==> [VALIDATE] Starting comprehensive validation process..."

validate_yaml_files "$(VARS_PATH_ABS)" "$(SCHEMAS_DIR_PATH_ABS)"

cd "$(COMPOSITION_PATH_ABS)"
echo "==> [VALIDATE] Running Terraform Init, Validate, and Plan..."
terraform init -backend=false
terraform validate
terraform plan -var-file="$(TFVARS_FILE)" -out=precheck.tfplan
terraform show -json precheck.tfplan > precheck.plan.json

if [ ! -s "precheck.plan.json" ]; then
    echo "FATAL: Terraform plan file is empty. This likely indicates an error during the plan phase."
    # In some cases, `terraform plan` can fail without a non-zero exit code. This check catches that.
    exit 1
fi

echo "--> Running DevSecOps Scanners..."
tflint --force
tfsec .
checkov --directory . --quiet
find "$(TF_PROJECT_ROOT)/policies/conftest" -name '*.rego' -print0 | xargs -0 -I {} conftest test precheck.plan.json --policy {} --no-color

echo "==> [VALIDATE] Validation and scanning completed successfully."