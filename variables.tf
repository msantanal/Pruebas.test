# Product variables
variable "name" {
  type        = string
  description = "(Required) Specifies the name of the Event Hub. Changing this forces a new resource to be created. Must be globally unique. See CCoE Naming section for all restrictions."
}

variable "namespace_name" {
  type        = string
  description = "(Required) Specifies the name of the Event Hub namespace. Changing this forces a new resource to be created. Must be globally unique. See CCoE Naming section for all restrictions."
}

variable "suffixnames_eh" {
  type        = list(string)
  description = "(Required) List of the suffix for the event Hub names"
}

variable "resource_group" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Event Hub."
}

variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "network_default_action" {
  type        = string
  description = "(Optional) The default action to take when a rule is not matched. Possible values are Allow and Deny. Defaults to Deny"
  default     = "Deny"
}

variable "event_hub_sku_tier" {
  type        = string
  description = "(Required) Specifies the tier of the Event Hub."
}

variable "event_hub_sku_capacity" {
  type        = number
  default     = 1
  description = "(Required) Specifies the capacity."
}

variable "event_hub_msg_retention" {
  type        = number
  default     = 7
  description = "(Required) Specifies the message retention."
}

variable "event_hub_partition_count" {
  type        = number
  default     = 1
  description = "(Required) Specifies the number of partitions."
}

variable "event_hub_ips_filter" {
  type        = list(string)
  description = "(Optional) List of IPs filter."
}

variable "event_hub_snet_ids" {
  type        = list(string)
  description = "(Optional) List of SubNets Ids."
}

variable "eventhub_auth_rules" {
  description = "Manages Event Hub authorization rules within an Event Hub. Specifies a list of objects, each object providing the name of the EventHub Authorization Rule resource and the rule permission (values are: listen, send or manage)."
  type = list(object({
    name       = string
    permission = string
    eh_name    = string
  }))

  validation {
    condition = alltrue([
      for o in var.eventhub_auth_rules : contains(["listen", "send", "manage"], o.permission)
    ])
    error_message = "All rules must have permission of either listen, send or manage."
  }
  default = []
}

variable "namespace_auth_rules" {
  description = "Manages Event Hub Namespace authorization rules within an Event Hub Namespace. Specifies a list of objects, each object providing the name of the Namespace Authorization Rule resource and the rule permission (values are: listen, send or manage)."
  type = list(object({
    name       = string
    permission = string
  }))

  validation {
    condition = alltrue([
      for o in var.namespace_auth_rules : contains(["listen", "send", "manage"], o.permission)
    ])
    error_message = "All rules must have permission of either listen, send or manage."
  }
  default = []
}

# Analytics Variables
variable "log_analytics_workspace_id" {
  type        = string
  description = "(Required) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent."
}

variable "lwk_resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group the LWK are located in."
}

variable "lwk_name" {
  description = "(Mandatory) Log Work Space Name to connect the product."
}

variable "analytics_diagnostic_monitor" {
  type        = string
  description = "(Required) Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created."
}


# Custom tags
variable "cia" {
  type        = string
  description = "(Mandatory) Specifies the confidentiality,integrity and availability of the Azure Event Hub."
}
variable "channel" {
  type        = string
  description = "(Optional) Distribution channel to which the associated resource belongs to."
  default     = ""
}
variable "description" {
  type        = string
  description = "(Required) Provide additional context information describing the resource and its purpose."
}
variable "tracking_code" {
  type        = string
  description = "(Optional) Allow this resource to be matched against internal inventory systems."
  default     = ""
}
variable "cost_center" {
  type        = string
  description = "(Required) This will allow in the initial phase to control the country/project cost."
  default     = ""
}
variable "product" {
  type        = string
  description = "(Required) The product tag will indicate the product to which the associated resource belongs to. Required to provide a global view of all resources dedicated to an application."
  default     = ""
}
