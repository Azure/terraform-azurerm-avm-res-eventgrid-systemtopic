terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.9.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0"
    }
  }
}

provider "azurerm" {
  features {}
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
  location = "eastus"
  name     = "test-rg-eventgrid-systemtopic-example"
}

# =========================================
# STORAGE ACCOUNT (Event Source)
# =========================================

resource "azurerm_storage_account" "example" {
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  location                  = azurerm_resource_group.example.location
  name                      = "steventgridsample41"
  resource_group_name       = azurerm_resource_group.example.name
  shared_access_key_enabled = false
  tags = {
    Environment = "Development"
    Purpose     = "EventGrid Source"
  }
}

# data "azurerm_storage_account" "example" {
#   name                = "teststgsytemtopic2"
#   resource_group_name = azurerm_resource_group.example.name
# }
# =========================================
# STORAGE QUEUE (Event Destination)
# =========================================

resource "azurerm_storage_queue" "events" {
  name                 = "eventgrid-events"
  storage_account_name = azurerm_storage_account.example.name
}

resource "azurerm_storage_queue" "events_deadletter" {
  name                 = "eventgrid-deadletter"
  storage_account_name = azurerm_storage_account.example.name
}

resource "azurerm_storage_container" "deadletter" {
  name                  = "deadletter"
  container_access_type = "private"
  storage_account_name  = azurerm_storage_account.example.name
}

# =========================================
# EVENT GRID SYSTEM TOPIC
# =========================================

module "eventgrid_system_topic" {
  source = "../.."

  location = azurerm_resource_group.example.location
  # Required Variables
  name                   = "evgt-storage-example"
  parent_id              = azurerm_resource_group.example.id
  source_arm_resource_id = azurerm_storage_account.example.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
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
            resource_id                           = azurerm_storage_account.example.id
            queue_name                            = azurerm_storage_queue.events.name
            queue_message_time_to_live_in_seconds = 300
          }
        }
      }

      dead_letter_destination = {
        storage_blob = {
          resource_id         = azurerm_storage_account.example.id
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





