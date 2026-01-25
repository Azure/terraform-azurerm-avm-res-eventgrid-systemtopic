resource "azapi_resource" "event_subscription" {
  type      = "Microsoft.EventGrid/systemTopics/eventSubscriptions@2025-04-01-preview"
  name      = var.name
  parent_id = var.system_topic_id

  body = {
    properties = {
      destination               = var.destination
      eventDeliverySchema       = var.event_delivery_schema
      filter                    = var.filter
      labels                    = var.labels
      retryPolicy               = var.retry_policy
      expirationTimeUtc         = var.expiration_time_utc
      deadLetterDestination     = var.dead_letter_destination
      deadLetterWithResourceIdentity = var.dead_letter_with_resource_identity
      deliveryWithResourceIdentity   = var.delivery_with_resource_identity
    }
  }

  response_export_values = ["*"]

  lifecycle {
    ignore_changes = [
      body.properties.destination
    ]
  }
}
