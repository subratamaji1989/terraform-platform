# Creates a flattened list of all rules from all security groups for easier iteration.
locals {
  # Example: [{ sg_key = "app_nsg", rule = { name = "allow_http", ... } }, ...]
  all_rules = flatten([
    for sg_key, sg_val in var.security_groups : [
      for rule in sg_val.rules : {
        sg_key = sg_key
        rule   = rule
      }
    ]
  ])

  # Example: [{ sg_key = "app_nsg", subnet_key = "app_subnet" }, ...]
  all_associations = flatten([
    for sg_key, sg_val in var.security_groups : [
      for subnet_key in sg_val.subnet_keys : {
        sg_key     = sg_key
        subnet_key = subnet_key
      } if lookup(var.subnet_ids_by_key, subnet_key, null) != null
    ]
  ])
}

# Creates Network Security Groups and their rules.
resource "azurerm_network_security_group" "this" {
  for_each            = var.security_groups
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Creates the rules for each NSG.
resource "azurerm_network_security_rule" "this" {
  for_each                    = { for item in local.all_rules : "${item.sg_key}-${item.rule.name}" => item }
  name                        = each.value.rule.name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  source_port_range           = each.value.rule.source_port_range
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = each.value.rule.source_address_prefix
  destination_address_prefix  = each.value.rule.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.sg_key].name
}

# Associates the NSGs with the specified subnets.
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = { for item in local.all_associations : "${item.sg_key}-${item.subnet_key}" => item }
  subnet_id                 = var.subnet_ids_by_key[each.value.subnet_key]
  network_security_group_id = azurerm_network_security_group.this[each.value.sg_key].id
}