# AKS Stack Composition

This directory contains the Terraform composition for the Azure Kubernetes Service (AKS) stack. It orchestrates the deployment of an AKS cluster and its required networking resources using the reusable modules from this platform.

## Purpose

The AKS stack composition serves as the main entry point for deploying a complete Kubernetes environment in Azure. It integrates the `network` and `aks` modules to create a cohesive and secure cluster, configured via data-driven input variables.

## Usage

To use this composition, you provide values for the input variables defined in `variables.tf`. These values are typically sourced from YAML configuration files (like `aks.yaml` and `network.yaml`) which are merged into a single `.tfvars.json` file by an orchestration script.

## Structure

- **main.tf**: Contains the main Terraform configuration that calls the `network` and `aks` modules.
- **variables.tf**: Defines the input variables required for this composition, such as cluster details and network configuration.
- **outputs.tf**: (Optional) Specifies outputs from the composition, allowing other configurations to access important values like the cluster name or endpoint.

## Example

Refer to the `variables.tf` file for a list of configurable parameters. The module documentation in `terraform-platform/azure/modules/` provides more detail on how each underlying resource is configured.

## Notes

This composition depends on the `network` and `aks` modules. Ensure they are available at the relative paths specified in `main.tf`.