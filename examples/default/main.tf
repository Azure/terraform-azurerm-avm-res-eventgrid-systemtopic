terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.9.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ebe3fefe-50cb-43ee-9643-509732d6a191"
}

provider "azapi" {
}

# =========================================
# DATA SOURCES
# =========================================

# Get current client configuration for AzAPI
data "azapi_client_config" "current" {}

# =========================================
# RESOURCE GROUP
# =========================================

resource "azurerm_resource_group" "example" {
  name     = "test-rg-eventgrid-systemtopic-example"
  location = "eastus"
}

# =========================================
# STORAGE ACCOUNT (Event Source)
# =========================================

# resource "azurerm_storage_account" "example" {
#   name                     = "steventgridsample41"
#   resource_group_name      = azurerm_resource_group.example.name
#   location                 = azurerm_resource_group.example.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   shared_access_key_enabled = false

#   tags = {
#     Environment = "Development"
#     Purpose     = "EventGrid Source"
#   }
# }

data "azurerm_storage_account" "example" {
  name                = "teststgsytemtopic2"
  resource_group_name = azurerm_resource_group.example.name
}
# =========================================
# STORAGE QUEUE (Event Destination)
# =========================================

resource "azurerm_storage_queue" "events" {
  name                 = "eventgrid-events"
  storage_account_name = data.azurerm_storage_account.example.name
}

resource "azurerm_storage_queue" "events_deadletter" {
  name                 = "eventgrid-deadletter"
  storage_account_name = data.azurerm_storage_account.example.name
}

resource "azurerm_storage_container" "deadletter" {
  name                  = "deadletter"
  storage_account_name  = data.azurerm_storage_account.example.name
  container_access_type = "private"
}

# =========================================
# EVENT GRID SYSTEM TOPIC
# =========================================

module "eventgrid_system_topic" {
  source = "../.."

  # Required Variables
  name                   = "evgt-storage-example"
  location               = azurerm_resource_group.example.location
  parent_id              = azurerm_resource_group.example.id
  source_arm_resource_id = data.azurerm_storage_account.example.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  # Optional: Enable System-Assigned Managed Identity
  identity = {
    type = "SystemAssigned"
  }

  # Optional: Add resource lock for production
  locks = {
    kind = "CanNotDelete"
    name = "lock-evgt-storage"
  }

  # Optional: Role Assignment for Event Grid system topic
  role_assignments = {
    storage_queue_sender = {
      role_definition_id_or_name = "Storage Queue Data Message Sender"
      principal_id               = data.azapi_client_config.current.object_id
      principal_type             = "User"
      description                = "Allow Event Grid to send messages to storage queue"
    }
  }

  # Optional: Event Subscriptions
  event_subscriptions = {
    storage_queue_subscription = {
      name = "es-storage-queue"

      delivery_with_resource_identity = {
        identity = {
          type = "SystemAssigned"
        }
        destination = {
          storage_queue = {
            resource_id                           = data.azurerm_storage_account.example.id
            queue_name                            = azurerm_storage_queue.events.name
            queue_message_time_to_live_in_seconds = 300
          }
        }
      }

      dead_letter_destination = {
        storage_blob = {
          resource_id         = data.azurerm_storage_account.example.id
          blob_container_name = azurerm_storage_container.deadletter.name
        }
      }

      filter = {
        subject_begins_with = "blobServices/default/containers/"
        included_event_types = [
          "Microsoft.Storage.BlobCreated",
          "Microsoft.Storage.BlobDeleted"
        ]
        is_subject_case_sensitive = false
      }

      retry_policy = {
        max_delivery_attempts         = 30
        event_time_to_live_in_minutes = 1440
      }

      labels = ["production", "storage-monitoring"]
    }
  }

  # Optional: Tags
  tags = {
    Environment = "Development"
    Example     = "Storage"
    ManagedBy   = "Terraform"
  }
}

# =========================================
# OUTPUTS
# =========================================

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
