# Required Variables

variable "location" {
  type        = string
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
DESCRIPTION
  nullable    = false
}

variable "name" {
  type        = string
  description = <<DESCRIPTION
The name of the this resource.
DESCRIPTION

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]{1,63}$", var.name))
    error_message = "The name must be between 1 and 63 characters and can contain only letters, numbers and hyphens."
  }
}

variable "parent_id" {
  type        = string
  description = <<DESCRIPTION
The ID of the resource group where the Event Grid System Topic will be deployed.
Format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}
DESCRIPTION

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", var.parent_id))
    error_message = "parent_id must be a valid resource group ID."
  }
}

variable "source_arm_resource_id" {
  type        = string
  description = "The ID of the Event Grid System Topic ARM Source. Changing this forces a new resource to be created."
  nullable    = false
}

variable "topic_type" {
  type        = string
  description = <<-EOT
    The Topic Type of the Event Grid System Topic. The topic type must match the source resource type.
    Possible values include:
    - Microsoft.Storage.StorageAccounts
    - Microsoft.EventHub.Namespaces
    - Microsoft.ServiceBus.Namespaces
    - Microsoft.KeyVault.Vaults
    - Microsoft.ContainerRegistry.Registries
    - Microsoft.Devices.IoTHubs
    - Microsoft.EventGrid.Domains
    - Microsoft.EventGrid.Topics
    - Microsoft.MachineLearningServices.Workspaces
    - Microsoft.Maps.Accounts
    - Microsoft.Media.MediaServices
    - Microsoft.Resources.ResourceGroups
    - Microsoft.Resources.Subscriptions
    - Microsoft.SignalRService.SignalR
    - Microsoft.Web.Sites
    - Microsoft.Web.ServerFarms
    - Microsoft.Communication.CommunicationServices
    - Microsoft.ApiManagement.Service
    - Microsoft.Cache.Redis
    - Microsoft.HealthcareApis.Services
    Changing this forces a new resource to be created.
  EOT
  nullable    = false
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<-EOT
    A map of diagnostic settings to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set.
    - `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
    - `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
    - `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
    - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
    - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
    - `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
    - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
    - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
    - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
  EOT
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "event_subscriptions" {
  type = map(object({
    name = string

    # Destination configuration - exactly one destination type should be specified
    destination = optional(object({
      # Azure Function destination
      azure_function = optional(object({
        resource_id                       = string
        max_events_per_batch              = optional(number)
        preferred_batch_size_in_kilobytes = optional(number)
        delivery_attribute_mappings = optional(list(object({
          name = string
          type = string # "Static" or "Dynamic"
          # For Static type
          value     = optional(string)
          is_secret = optional(bool)
          # For Dynamic type
          source_field = optional(string)
        })))
      }))

      # Event Hub destination
      event_hub = optional(object({
        resource_id = string
        delivery_attribute_mappings = optional(list(object({
          name = string
          type = string # "Static" or "Dynamic"
          # For Static type
          value     = optional(string)
          is_secret = optional(bool)
          # For Dynamic type
          source_field = optional(string)
        })))
      }))

      # Hybrid Connection destination
      hybrid_connection = optional(object({
        resource_id = string
        delivery_attribute_mappings = optional(list(object({
          name = string
          type = string # "Static" or "Dynamic"
          # For Static type
          value     = optional(string)
          is_secret = optional(bool)
          # For Dynamic type
          source_field = optional(string)
        })))
      }))

      # Monitor Alert destination
      monitor_alert = optional(object({
        severity      = string # "Sev0", "Sev1", "Sev2", "Sev3", "Sev4"
        action_groups = optional(list(string))
        description   = optional(string)
      }))

      # Namespace Topic destination
      namespace_topic = optional(object({
        resource_id = string
      }))

      # Service Bus Queue destination
      service_bus_queue = optional(object({
        resource_id = string
        delivery_attribute_mappings = optional(list(object({
          name = string
          type = string # "Static" or "Dynamic"
          # For Static type
          value     = optional(string)
          is_secret = optional(bool)
          # For Dynamic type
          source_field = optional(string)
        })))
      }))

      # Service Bus Topic destination
      service_bus_topic = optional(object({
        resource_id = string
        delivery_attribute_mappings = optional(list(object({
          name = string
          type = string # "Static" or "Dynamic"
          # For Static type
          value     = optional(string)
          is_secret = optional(bool)
          # For Dynamic type
          source_field = optional(string)
        })))
      }))

      # Storage Queue destination
      storage_queue = optional(object({
        resource_id                           = string
        queue_name                            = string
        queue_message_time_to_live_in_seconds = optional(number)
      }))

      # WebHook destination
      webhook = optional(object({
        endpoint_url                         = string
        max_events_per_batch                 = optional(number)
        preferred_batch_size_in_kilobytes    = optional(number)
        azure_active_directory_tenant_id     = optional(string)
        azure_active_directory_app_id_or_uri = optional(string)
        minimum_tls_version_allowed          = optional(string) # "1.0", "1.1", "1.2"
        delivery_attribute_mappings = optional(list(object({
          name = string
          type = string # "Static" or "Dynamic"
          # For Static type
          value     = optional(string)
          is_secret = optional(bool)
          # For Dynamic type
          source_field = optional(string)
        })))
      }))
    }))

    # Delivery with managed identity - use this for RBAC-based delivery
    delivery_with_resource_identity = optional(object({
      identity = object({
        type                   = string # "SystemAssigned" or "UserAssigned"
        user_assigned_identity = optional(string)
      })
      destination = object({
        # Same destination types as above
        azure_function = optional(object({
          resource_id                       = string
          max_events_per_batch              = optional(number)
          preferred_batch_size_in_kilobytes = optional(number)
          delivery_attribute_mappings = optional(list(object({
            name         = string
            type         = string
            value        = optional(string)
            is_secret    = optional(bool)
            source_field = optional(string)
          })))
        }))
        event_hub = optional(object({
          resource_id = string
          delivery_attribute_mappings = optional(list(object({
            name         = string
            type         = string
            value        = optional(string)
            is_secret    = optional(bool)
            source_field = optional(string)
          })))
        }))
        hybrid_connection = optional(object({
          resource_id = string
          delivery_attribute_mappings = optional(list(object({
            name         = string
            type         = string
            value        = optional(string)
            is_secret    = optional(bool)
            source_field = optional(string)
          })))
        }))
        monitor_alert = optional(object({
          severity      = string
          action_groups = optional(list(string))
          description   = optional(string)
        }))
        namespace_topic = optional(object({
          resource_id = string
        }))
        service_bus_queue = optional(object({
          resource_id = string
          delivery_attribute_mappings = optional(list(object({
            name         = string
            type         = string
            value        = optional(string)
            is_secret    = optional(bool)
            source_field = optional(string)
          })))
        }))
        service_bus_topic = optional(object({
          resource_id = string
          delivery_attribute_mappings = optional(list(object({
            name         = string
            type         = string
            value        = optional(string)
            is_secret    = optional(bool)
            source_field = optional(string)
          })))
        }))
        storage_queue = optional(object({
          resource_id                           = string
          queue_name                            = string
          queue_message_time_to_live_in_seconds = optional(number)
        }))
        webhook = optional(object({
          endpoint_url                         = string
          max_events_per_batch                 = optional(number)
          preferred_batch_size_in_kilobytes    = optional(number)
          azure_active_directory_tenant_id     = optional(string)
          azure_active_directory_app_id_or_uri = optional(string)
          minimum_tls_version_allowed          = optional(string)
          delivery_attribute_mappings = optional(list(object({
            name         = string
            type         = string
            value        = optional(string)
            is_secret    = optional(bool)
            source_field = optional(string)
          })))
        }))
      })
    }))

    # Dead letter destination (StorageBlob only)
    dead_letter_destination = optional(object({
      storage_blob = object({
        resource_id         = string
        blob_container_name = string
      })
    }))

    # Dead letter with managed identity
    dead_letter_with_resource_identity = optional(object({
      identity = object({
        type                   = string # "SystemAssigned" or "UserAssigned"
        user_assigned_identity = optional(string)
      })
      dead_letter_destination = object({
        storage_blob = object({
          resource_id         = string
          blob_container_name = string
        })
      })
    }))

    # Event delivery schema
    event_delivery_schema = optional(string) # "EventGridSchema", "CloudEventSchemaV1_0", "CustomInputSchema"

    # Expiration time
    expiration_time_utc = optional(string)

    # Filter configuration
    filter = optional(object({
      subject_begins_with                 = optional(string)
      subject_ends_with                   = optional(string)
      included_event_types                = optional(list(string))
      is_subject_case_sensitive           = optional(bool)
      enable_advanced_filtering_on_arrays = optional(bool)
      advanced_filters = optional(list(object({
        key           = string
        operator_type = string
        # For single value operators (NumberGreaterThan, NumberLessThan, etc.)
        value = optional(any)
        # For multi-value operators (StringIn, NumberIn, etc.)
        values = optional(list(any))
      })))
    }))

    # Labels
    labels = optional(list(string))

    # Retry policy
    retry_policy = optional(object({
      max_delivery_attempts         = optional(number)
      event_time_to_live_in_minutes = optional(number)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
A map of event subscriptions to create on the Event Grid System Topic.

Each event subscription supports the following:

- `name` - (Required) The name of the event subscription.

- `destination` - (Optional) Direct delivery destination. Specify exactly one destination type:
  - `azure_function` - Azure Function destination with `resource_id`, optional `max_events_per_batch`, `preferred_batch_size_in_kilobytes`, and `delivery_attribute_mappings`.
  - `event_hub` - Event Hub destination with `resource_id` and optional `delivery_attribute_mappings`.
  - `hybrid_connection` - Hybrid Connection destination with `resource_id` and optional `delivery_attribute_mappings`.
  - `monitor_alert` - Monitor Alert destination with `severity` (Sev0-Sev4), optional `action_groups` and `description`.
  - `namespace_topic` - Event Grid Namespace Topic destination with `resource_id`.
  - `service_bus_queue` - Service Bus Queue destination with `resource_id` and optional `delivery_attribute_mappings`.
  - `service_bus_topic` - Service Bus Topic destination with `resource_id` and optional `delivery_attribute_mappings`.
  - `storage_queue` - Storage Queue destination with `resource_id`, `queue_name`, and optional `queue_message_time_to_live_in_seconds`.
  - `webhook` - WebHook destination with `endpoint_url`, optional `max_events_per_batch`, `preferred_batch_size_in_kilobytes`, `azure_active_directory_tenant_id`, `azure_active_directory_app_id_or_uri`, `minimum_tls_version_allowed`, and `delivery_attribute_mappings`.

- `delivery_with_resource_identity` - (Optional) Delivery using managed identity (recommended for secure RBAC-based delivery):
  - `identity` - Identity configuration with `type` ("SystemAssigned" or "UserAssigned") and optional `user_assigned_identity`.
  - `destination` - Same destination types as above.

- `dead_letter_destination` - (Optional) Dead letter destination (only StorageBlob supported):
  - `storage_blob` - Storage blob with `resource_id` and `blob_container_name`.

- `dead_letter_with_resource_identity` - (Optional) Dead letter using managed identity.

- `event_delivery_schema` - (Optional) Schema for delivered events: "EventGridSchema", "CloudEventSchemaV1_0", "CustomInputSchema".

- `filter` - (Optional) Event filtering configuration:
  - `subject_begins_with` - Subject prefix filter.
  - `subject_ends_with` - Subject suffix filter.
  - `included_event_types` - List of event types to include.
  - `is_subject_case_sensitive` - Case sensitivity for subject filters.
  - `enable_advanced_filtering_on_arrays` - Enable advanced filtering on arrays.
  - `advanced_filters` - List of advanced filters with `key`, `operator_type`, `value`, and `values`.

- `labels` - (Optional) List of labels.

- `retry_policy` - (Optional) Retry policy with `max_delivery_attempts` and `event_time_to_live_in_minutes`.

Example - Storage Queue with managed identity for storage account events:
```hcl
event_subscriptions = {
  storage_queue_sub = {
    name = "my-storage-queue-subscription"
    delivery_with_resource_identity = {
      identity = {
        type = "SystemAssigned"
      }
      destination = {
        storage_queue = {
          resource_id                           = "/subscriptions/.../storageAccounts/mystorageaccount"
          queue_name                            = "myqueue"
          queue_message_time_to_live_in_seconds = 300
        }
      }
    }
    filter = {
      subject_begins_with = "blobServices/default/containers/"
      included_event_types = ["Microsoft.Storage.BlobCreated", "Microsoft.Storage.BlobDeleted"]
    }
  }
}
```

Example - WebHook destination for system topic events:
```hcl
event_subscriptions = {
  webhook_sub = {
    name = "my-webhook-subscription"
    destination = {
      webhook = {
        endpoint_url          = "https://example.com/webhook"
        max_events_per_batch  = 10
        minimum_tls_version_allowed = "1.2"
      }
    }
    filter = {
      included_event_types = ["Microsoft.Storage.BlobCreated"]
    }
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for k, v in var.event_subscriptions :
      v.name != null && (v.destination != null || v.delivery_with_resource_identity != null)
    ])
    error_message = "Each event subscription must have a 'name' and either 'destination' or 'delivery_with_resource_identity'."
  }
  validation {
    condition = alltrue([
      for k, v in var.event_subscriptions :
      v.event_delivery_schema == null ? true : contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomInputSchema"], v.event_delivery_schema)
    ])
    error_message = "event_delivery_schema must be one of: 'EventGridSchema', 'CloudEventSchemaV1_0', 'CustomInputSchema'."
  }
}

# Optional Variables
variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default     = null
  description = <<-EOT
    An identity block that defines the managed identity configuration.
    - type: The type of Managed Service Identity. Possible values are 'SystemAssigned', 'UserAssigned', 'SystemAssigned, UserAssigned'
    - identity_ids: A list of User Assigned Managed Identity IDs (required when type is 'UserAssigned' or 'SystemAssigned, UserAssigned')
  EOT
}

variable "locks" {
  type = object({
    name = optional(string, null)
    kind = string
  })
  default     = null
  description = <<-EOT
    Controls the Resource Lock configuration for this resource. The following properties can be specified:
    - `kind` - (Required) The type of lock. Possible values are 'CanNotDelete' and 'ReadOnly'.
    - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value.
  EOT
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
  }))
  default     = {}
  description = <<-EOT
    A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `role_definition_id_or_name` - (Required) The ID or name of the role definition to assign to the principal.
    - `principal_id` - (Required) The ID of the principal to assign the role to.
    - `condition` - (Optional) The condition which will be used when creating a role assignment.
    - `condition_version` - (Optional) The version of the condition. Possible values are "2.0". Leave blank if no condition is used.
    - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity.
    - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group`, `ServicePrincipal` and `ForeignGroup`.
    - `skip_service_principal_aad_check` - (Optional) If the principal_id is a newly provisioned Service Principal set this value to true to skip the Azure Active Directory check which may fail due to replication lag.
  EOT
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the Event Grid System Topic."
}
