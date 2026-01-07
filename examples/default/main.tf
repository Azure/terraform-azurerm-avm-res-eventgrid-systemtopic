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
  storage_use_azuread = true
}

provider "azapi" {
}

# =========================================
# DATA SOURCES
# =========================================
data "azurerm_client_config" "current" {}
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
  name                      = "steventgridsample42"
  resource_group_name       = azurerm_resource_group.example.name
  local_user_enabled        = false
  shared_access_key_enabled = false
  tags = {
    Environment = "Development"
    Purpose     = "EventGrid Source"
  }
}

# =========================================
# RBAC ASSIGNMENTS FOR TERRAFORM IDENTITY
# =========================================

# Grant Storage Blob Data Contributor to Terraform identity for blob operations
resource "azurerm_role_assignment" "terraform_blob_contributor" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
}

# Grant Storage Queue Data Contributor to Terraform identity for queue operations
resource "azurerm_role_assignment" "terraform_queue_contributor" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Queue Data Contributor"
}

# data "azurerm_storage_account" "example" {
#   name                = "teststgsytemtopic2"
#   resource_group_name = azurerm_resource_group.example.name
# }
# =========================================
# STORAGE QUEUE (Event Destination)
# =========================================

resource "azurerm_storage_queue" "events" {
  name               = "eventgrid-events"
  storage_account_id = azurerm_storage_account.example.id

  depends_on = [azurerm_role_assignment.terraform_queue_contributor]
}

resource "azurerm_storage_queue" "events_deadletter" {
  name               = "eventgrid-deadletter"
  storage_account_id = azurerm_storage_account.example.id

  depends_on = [azurerm_role_assignment.terraform_queue_contributor]
}

resource "azurerm_storage_container" "deadletter" {
  name                  = "deadletter"
  container_access_type = "private"
  storage_account_id    = azurerm_storage_account.example.id

  depends_on = [azurerm_role_assignment.terraform_blob_contributor]
}

# =========================================
# USER-ASSIGNED MANAGED IDENTITY FOR EVENT SUBSCRIPTION
# =========================================

resource "azurerm_user_assigned_identity" "eventgrid_subscription" {
  location            = azurerm_resource_group.example.location
  name                = "id-eventgrid-subscription"
  resource_group_name = azurerm_resource_group.example.name
}

# Grant the identity permission to send to storage queue
resource "azurerm_role_assignment" "eventgrid_queue_sender" {
  principal_id         = azurerm_user_assigned_identity.eventgrid_subscription.principal_id
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Queue Data Message Sender"
}

# Grant the identity permission to write to deadletter blob
resource "azurerm_role_assignment" "eventgrid_blob_contributor" {
  principal_id         = azurerm_user_assigned_identity.eventgrid_subscription.principal_id
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
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
          type                   = "UserAssigned"
          user_assigned_identity = azurerm_user_assigned_identity.eventgrid_subscription.id
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
  # Optional: Tags
  tags = {
    Environment = "Development"
    Example     = "Storage"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    azurerm_role_assignment.eventgrid_queue_sender,
    azurerm_role_assignment.eventgrid_blob_contributor
  ]
}

# =========================================
# OUTPUTS
# =========================================





