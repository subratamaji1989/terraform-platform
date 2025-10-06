# Azure VM Stack Composition

This directory contains the Terraform composition for deploying a stack of Azure Virtual Machines. It orchestrates the deployment of network resources, security groups, and virtual machines using the reusable modules from this platform.

## Purpose

The VM stack composition serves as the main entry point for deploying a complete virtual machine environment in Azure. It integrates the `network` and `vm` modules and directly manages Network Security Groups to create a cohesive and secure environment, configured via data-driven input variables.

## Usage

To use this composition, you provide values for the input variables defined in `variables.tf`. These values are typically sourced from YAML configuration files (like `vm.yaml`, `network.yaml`, and `security.yaml`) which are merged into a single `.tfvars.json` file by an orchestration script.

## Structure

- **main.tf**: Contains the main Terraform configuration that calls the `network` and `vm` modules and creates NSG resources.
- **variables.tf**: Defines the input variables required for this composition, such as VM details and network configuration.
- **outputs.tf**: Specifies outputs from the composition, allowing other configurations to access important values like VM IDs and private IPs.

## Example

Refer to the `variables.tf` file for a list of configurable parameters. The module documentation in `terraform-platform/azure/modules/` provides more detail on how each underlying resource is configured.

## Notes

This composition depends on the `network` and `vm` modules. Ensure they are available at the relative paths specified in `main.tf`.