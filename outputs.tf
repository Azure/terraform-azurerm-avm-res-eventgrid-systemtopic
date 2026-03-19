output "name" {
  description = "The name of the EventGrid System Topic."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The EventGrid System Topic resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the EventGrid System Topic."
  value       = azapi_resource.this.id
}
