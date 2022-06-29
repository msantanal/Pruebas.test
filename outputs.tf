output "name" {
  # value = "${azurerm_eventhub_namespace.eventhubns.name}"
  value = var.namespace_name
}

output "id" {
  value = azurerm_eventhub_namespace.eventhubns.id
}
