# Event Subscription Submodule for System Topics

This submodule creates an Event Grid event subscription on an Event Grid System Topic.

## Purpose

This submodule can be used independently to create event subscriptions on:

- Event Grid System Topics created by the parent module
- **Existing Event Grid System Topics** not managed by Terraform

This enables scenarios where:

- The system topic is managed by a different team
- The system topic was created outside of Terraform
- Multiple subscriptions need to be added incrementally to an existing system topic

## Usage

### On an existing system topic (not managed by Terraform)

```hcl
module "my_subscription" {
  source = "Azure/avm-res-eventgrid-systemtopic/azurerm//modules/event_subscription"

  name                    = "my-subscription"
  system_topic_resource_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.EventGrid/systemTopics/existing-system-topic"

  destination = {
    storage_queue = {
      resource_id                           = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Storage/storageAccounts/mystorageaccount"
      queue_name                            = "events"
      queue_message_time_to_live_in_seconds = 300
    }
  }

  filter = {
    subject_begins_with = "blobServices/default/containers/"
    included_event_types = ["Microsoft.Storage.BlobCreated"]
  }
}
```

### With managed identity delivery (recommended)

```hcl
module "my_subscription" {
  source = "Azure/avm-res-eventgrid-systemtopic/azurerm//modules/event_subscription"

  name                    = "my-subscription"
  system_topic_resource_id = module.eventgrid_system_topic.resource_id

  delivery_with_resource_identity = {
    identity = {
      type = "SystemAssigned"
    }
    destination = {
      storage_queue = {
        resource_id                           = azurerm_storage_account.example.id
        queue_name                            = "events"
        queue_message_time_to_live_in_seconds = 300
      }
    }
  }

  dead_letter_destination = {
    storage_blob = {
      resource_id         = azurerm_storage_account.example.id
      blob_container_name = "deadletters"
    }
  }

  depends_on = [azurerm_role_assignment.eventgrid_to_storage]
}
```
