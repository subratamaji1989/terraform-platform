# This file ensures that this module uses the correct provider version passed down from the root composition.

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}