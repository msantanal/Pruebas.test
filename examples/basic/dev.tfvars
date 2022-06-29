resource_group          = "pgxd1weursgglobalplat001"
lwk_name                = "pgxd1weulwkglobalplat001"
lwk_resource_group_name = "pgxd1weursgglobalplat001"
namespace_name          = "pgxd1weuaehdglobalplat001-ns"
event_hub_sku_tier      = "Standard"
location                = "westeurope"

suffixnames_eh = ["_apicontainer", "_productcontainer"]
name           = "pgxd1weuaehdglobalplat001"

eventhub_auth_rules = [
  {
    name       = "test_rule"
    permission = "listen"
    eh_name    = "pgxd1weuaehdglobalplat001_apicontainer"
}]
namespace_auth_rules = [
  {
    name       = "test_namespace_rule"
    permission = "listen"
}]

analytics_diagnostic_monitor = "Example Event Hub Monitor"

event_hub_ips_filter = []
event_hub_snet_ids   = []

cost_center   = "cost_center"
product       = "product"
channel       = "channel"
description   = "description"
tracking_code = "tracking_code"
cia           = "cia"