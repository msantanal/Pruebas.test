data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

data "azurerm_log_analytics_workspace" "law" {
  name                = var.lwk_name
  resource_group_name = var.lwk_resource_group_name
}

data "template_file" "templateIPFilterVsnEndPoint" {
  template = file("${path.module}/scripts/arm/IPFilter_VsnEndPoint.json")
}

data "template_file" "templateIPFilter" {
  template = file("${path.module}/scripts/arm/IPFilter.json")
}

data "template_file" "templateVsnEndPoint" {
  template = file("${path.module}/scripts/arm/VsnEndPoint.json")
}

data "template_file" "templateAllInternetAccess" {
  template = file("${path.module}/scripts/arm/AllInternetAccess.json")
}

resource "azurerm_eventhub_namespace" "eventhubns" {

  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = var.event_hub_sku_tier
  capacity            = var.event_hub_sku_capacity

  network_rulesets {
    default_action = var.network_default_action
  }

  #kafka_enabled       = true

  tags = {
    cost_center   = var.cost_center == "" ? data.azurerm_resource_group.rg.tags["cost_center"] : var.cost_center
    product       = var.product == "" ? data.azurerm_resource_group.rg.tags["product"] : var.product
    channel       = var.channel
    description   = var.description
    tracking_code = var.tracking_code
    cia           = var.cia
    bs            = data.azurerm_resource_group.rg.tags["BS"]
    ts            = data.azurerm_resource_group.rg.tags["TS"]
    sc            = data.azurerm_resource_group.rg.tags["SC"]
  }
}

resource "azurerm_eventhub" "eh" {
  count               = length(var.suffixnames_eh)
  name                = "${var.name}${var.suffixnames_eh[count.index]}"
  namespace_name      = azurerm_eventhub_namespace.eventhubns.name
  resource_group_name = var.resource_group
  partition_count     = var.event_hub_partition_count
  message_retention   = var.event_hub_msg_retention

  depends_on = [azurerm_eventhub_namespace.eventhubns]
}

resource "azurerm_eventhub_authorization_rule" "main" {
  count               = length(var.eventhub_auth_rules)
  name                = var.eventhub_auth_rules[count.index].name
  namespace_name      = azurerm_eventhub_namespace.eventhubns.name
  eventhub_name       = var.eventhub_auth_rules[count.index].eh_name
  resource_group_name = data.azurerm_resource_group.rg.name

  listen = var.eventhub_auth_rules[count.index].permission == "listen" || var.eventhub_auth_rules[count.index].permission == "manage" ? true : false
  send   = var.eventhub_auth_rules[count.index].permission == "send" || var.eventhub_auth_rules[count.index].permission == "manage" ? true : false
  manage = var.eventhub_auth_rules[count.index].permission == "manage" ? true : false
}

resource "azurerm_eventhub_namespace_authorization_rule" "main" {
  count               = length(var.namespace_auth_rules)
  name                = var.namespace_auth_rules[count.index].name
  namespace_name      = azurerm_eventhub_namespace.eventhubns.name
  resource_group_name = data.azurerm_resource_group.rg.name

  listen = var.eventhub_auth_rules[count.index].permission == "listen" || var.eventhub_auth_rules[count.index].permission == "manage" ? true : false
  send   = var.eventhub_auth_rules[count.index].permission == "send" || var.eventhub_auth_rules[count.index].permission == "manage" ? true : false
  manage = var.eventhub_auth_rules[count.index].permission == "manage" ? true : false
}

resource "azurerm_monitor_diagnostic_setting" "diagnostics_monitor_evenhub" {
  name                       = var.analytics_diagnostic_monitor
  target_resource_id         = azurerm_eventhub_namespace.eventhubns.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "ArchiveLogs"
    enabled  = true

    retention_policy {
      enabled = false
      days    = "30"
    }
  }

  log {
    category = "OperationalLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = "30"
    }
  }

  log {
    category = "AutoScaleLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = "30"
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = "30"
    }
  }
  depends_on = [data.azurerm_log_analytics_workspace.law, azurerm_eventhub_namespace.eventhubns]
}

locals {
  condition  = length(var.event_hub_ips_filter) != 0 && length(var.event_hub_snet_ids) != 0
  condition2 = length(var.event_hub_ips_filter) != 0 && length(var.event_hub_snet_ids) == 0
  condition3 = length(var.event_hub_ips_filter) == 0 && length(var.event_hub_snet_ids) != 0
  condition4 = length(var.event_hub_ips_filter) == 0 && length(var.event_hub_snet_ids) == 0 && var.network_default_action == "Allow"
}

resource "azurerm_template_deployment" "IPFilterVsnEndPoint" {

  count = local.condition ? 1 : 0

  name                = "IPFilterVsnEndPointTemplate"
  resource_group_name = var.resource_group
  template_body       = data.template_file.templateIPFilterVsnEndPoint.rendered

  parameters = {
    eventhubNamespaceName = azurerm_eventhub_namespace.eventhubns.name
    ips                   = join(",", var.event_hub_ips_filter)
    subnetIds             = join(",", var.event_hub_snet_ids)
  }

  deployment_mode = "Incremental"

  depends_on = [azurerm_eventhub.eh]
}

resource "azurerm_template_deployment" "IPFilter" {

  count = local.condition2 ? 1 : 0

  name                = "IPFilterTemplate"
  resource_group_name = var.resource_group
  template_body       = data.template_file.templateIPFilter.rendered

  parameters = {
    eventhubNamespaceName = azurerm_eventhub_namespace.eventhubns.name
    ips                   = join(",", var.event_hub_ips_filter)
  }

  deployment_mode = "Incremental"

  depends_on = [azurerm_eventhub.eh]
}

resource "azurerm_template_deployment" "VsnEndPoint" {

  count = local.condition3 ? 1 : 0

  name                = "VsnEndPointTemplate"
  resource_group_name = var.resource_group
  template_body       = data.template_file.templateVsnEndPoint.rendered

  parameters = {
    eventhubNamespaceName = azurerm_eventhub_namespace.eventhubns.name
    subnetIds             = join(",", var.event_hub_snet_ids)
  }

  deployment_mode = "Incremental"

  depends_on = [azurerm_eventhub.eh]
}

resource "azurerm_template_deployment" "AllInternetAccess" {

  count = local.condition4 ? 1 : 0

  name                = "AllInternetAccessTemplate"
  resource_group_name = var.resource_group
  template_body       = data.template_file.templateAllInternetAccess.rendered

  parameters = {
    eventhubNamespaceName = azurerm_eventhub_namespace.eventhubns.name
  }

  deployment_mode = "Incremental"

  depends_on = [azurerm_eventhub.eh]
}