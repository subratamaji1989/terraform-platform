# This file ensures that the composition uses the correct provider version.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Align with the lock file and use the 4.x provider series.
    }
  }
}