
module "main" {
  source = "../../"

  resource_group          = var.resource_group
  lwk_name                = var.lwk_name
  lwk_resource_group_name = var.lwk_resource_group_name
  namespace_name          = var.namespace_name
  event_hub_sku_tier      = var.event_hub_sku_tier
  location                = var.location

  suffixnames_eh = var.suffixnames_eh
  name           = var.name

  analytics_diagnostic_monitor = var.analytics_diagnostic_monitor
  log_analytics_workspace_id   = "/subscriptions/fcf6e046-14eb-409a-9374-fa3ee6be2fd8/resourcegroups/pgxd1weursgglobalplat001/providers/microsoft.operationalinsights/workspaces/pgxd1weulwkglobalplat001"

  eventhub_auth_rules  = var.eventhub_auth_rules
  namespace_auth_rules = var.namespace_auth_rules

  event_hub_ips_filter = var.event_hub_ips_filter
  event_hub_snet_ids   = var.event_hub_snet_ids

  cost_center   = var.cost_center
  product       = var.product
  channel       = var.channel
  description   = var.description
  tracking_code = var.tracking_code
  cia           = var.cia
}
