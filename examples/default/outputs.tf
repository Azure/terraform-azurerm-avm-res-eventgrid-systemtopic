output "event_subscriptions" {
  description = "Event subscriptions created on the system topic"
  value = {
    ids   = module.eventgrid_system_topic.event_subscription_ids
    names = module.eventgrid_system_topic.event_subscription_names
  }
}

output "storage_account_id" {
  description = "The ID of the Storage Account (Event Source)"
  value       = data.azurerm_storage_account.example.id
}

output "system_topic_id" {
  description = "The ID of the Event Grid System Topic"
  value       = module.eventgrid_system_topic.resource_id
}

output "system_topic_name" {
  description = "The name of the Event Grid System Topic"
  value       = module.eventgrid_system_topic.name
}

output "system_topic_principal_id" {
  description = "The Principal ID of the System Topic (system-assigned identity)"
  value       = module.eventgrid_system_topic.system_assigned_mi_principal_id
}
