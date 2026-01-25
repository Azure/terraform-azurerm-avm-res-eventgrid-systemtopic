output "resource" {
  description = "The EventGrid Event Subscription resource."
  value       = azapi_resource.event_subscription
}

output "resource_id" {
  description = "The resource ID of the EventGrid Event Subscription."
  value       = azapi_resource.event_subscription.id
}

output "name" {
  description = "The name of the EventGrid Event Subscription."
  value       = azapi_resource.event_subscription.name
}
