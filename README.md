# Azure Event Grid System Topic Terraform Module

This Terraform module creates an Azure Event Grid System Topic with comprehensive configuration options using the **AzAPI** provider.

## Features

- ✅ Azure Event Grid System Topic creation
- ✅ AzAPI provider for latest Azure features
- ✅ Managed Identity support (System, User, or both)
- ✅ Resource locks (CanNotDelete, ReadOnly)
- ✅ Role-based access control (RBAC)
- ✅ Diagnostic settings (Log Analytics, Storage, Event Hub)
- ✅ Comprehensive tagging
- ✅ Azure Verified Module (AVM) compliant
- ✅ Full argument coverage

## Supported Event Sources

The module supports all Azure Event Grid System Topic types:

- **Storage**: `Microsoft.Storage.StorageAccounts`
- **Event Hub**: `Microsoft.EventHub.Namespaces`
- **Service Bus**: `Microsoft.ServiceBus.Namespaces`
- **Key Vault**: `Microsoft.KeyVault.Vaults`
- **Container Registry**: `Microsoft.ContainerRegistry.Registries`
- **IoT Hub**: `Microsoft.Devices.IoTHubs`
- **Event Grid**: `Microsoft.EventGrid.Domains`, `Microsoft.EventGrid.Topics`
- **Machine Learning**: `Microsoft.MachineLearningServices.Workspaces`
- **Azure Maps**: `Microsoft.Maps.Accounts`
- **Media Services**: `Microsoft.Media.MediaServices`
- **Resources**: `Microsoft.Resources.ResourceGroups`, `Microsoft.Resources.Subscriptions`
- **SignalR**: `Microsoft.SignalRService.SignalR`
- **Web Apps**: `Microsoft.Web.Sites`, `Microsoft.Web.ServerFarms`
- **Communication Services**: `Microsoft.Communication.CommunicationServices`
- **API Management**: `Microsoft.ApiManagement.Service`
- **Redis Cache**: `Microsoft.Cache.Redis`
- **Healthcare APIs**: `Microsoft.HealthcareApis.Services`

## Usage

### Basic Example

```hcl
module "eventgrid_system_topic" {
  source = "./avm-res-eventgrid-systemtopic"

  name                   = "evgt-storage-events"
  location               = "eastus"
  parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-eventgrid"
  source_arm_resource_id = azurerm_storage_account.example.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Advanced Example with All Features

```hcl
module "eventgrid_system_topic_full" {
  source = "./avm-res-eventgrid-systemtopic"

  # Required arguments
  name                   = "evgt-storage-advanced"
  location               = "eastus"
  parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-eventgrid"
  source_arm_resource_id = azurerm_storage_account.example.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  # Managed Identity
  identity = {
    type = "SystemAssigned"
  }

  # Resource Lock
  locks = {
    kind = "CanNotDelete"
    name = "eventgrid-lock"
  }

  # Role Assignments
  role_assignments = {
    contributor = {
      role_definition_id_or_name = "EventGrid EventSubscription Contributor"
      principal_id               = "00000000-0000-0000-0000-000000000000"
      description                = "Contributor access for Event Grid"
      principal_type             = "User"
    }
  }

  # Diagnostic Settings
  diagnostic_settings = {
    log_analytics = {
      name                  = "diag-logs"
      workspace_resource_id = azurerm_log_analytics_workspace.example.id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  }

  # Tags
  tags = {
    Environment = "Production"
    Project     = "EventGrid"
    ManagedBy   = "Terraform"
  }
}
```

### User-Assigned Managed Identity

```hcl
module "eventgrid_with_uai" {
  source = "./avm-res-eventgrid-systemtopic"

  name                   = "evgt-uai-example"
  location               = "eastus"
  parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-eventgrid"
  source_arm_resource_id = azurerm_storage_account.example.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }
}
```

### Multiple Event Sources Examples

#### Storage Account Events
```hcl
module "storage_events" {
  source = "./avm-res-eventgrid-systemtopic"

  name                   = "evgt-storage"
  location               = "eastus"
  parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-eventgrid"
  source_arm_resource_id = azurerm_storage_account.example.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}
```

#### IoT Hub Events
```hcl
module "iothub_events" {
  source = "./avm-res-eventgrid-systemtopic"

  name                   = "evgt-iothub"
  location               = "eastus"
  parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-eventgrid"
  source_arm_resource_id = azurerm_iothub.example.id
  topic_type             = "Microsoft.Devices.IoTHubs"
}
```

#### Container Registry Events
```hcl
module "acr_events" {
  source = "./avm-res-eventgrid-systemtopic"

  name                   = "evgt-acr"
  location               = "eastus"
  parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-eventgrid"
  source_arm_resource_id = azurerm_container_registry.example.id
  topic_type             = "Microsoft.ContainerRegistry.Registries"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| azapi | >= 1.9.0 |

## Providers

| Name | Version |
|------|---------|
| azapi | >= 1.9.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Event Grid System Topic | `string` | n/a | yes |
| location | The Azure Region | `string` | n/a | yes |
| parent_id | The resource ID of the parent resource group | `string` | n/a | yes |
| source_arm_resource_id | The ID of the Event Grid System Topic ARM Source | `string` | n/a | yes |
| topic_type | The Topic Type of the Event Grid System Topic | `string` | n/a | yes |
| identity | Managed identity configuration | `object({...})` | `null` | no |
| tags | A mapping of tags | `map(string)` | `{}` | no |
| locks | Resource lock configuration | `object({...})` | `null` | no |
| role_assignments | Role assignments configuration | `map(object({...}))` | `{}` | no |
| diagnostic_settings | Diagnostic settings configuration | `map(object({...}))` | `{}` | no |
| event_subscriptions | Event subscriptions configuration | `map(object({...}))` | `{}` | no |
| enable_telemetry | Enable telemetry | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Event Grid System Topic |
| name | The name of the Event Grid System Topic |
| resource_id | The resource ID of the Event Grid System Topic |
| system_topic_id | The ID of the Event Grid System Topic |
| system_topic_name | The name of the Event Grid System Topic |
| system_topic_location | The location of the Event Grid System Topic |
| system_topic_tags | The tags assigned to the Event Grid System Topic |
| identity | The identity configuration |
| system_assigned_mi_principal_id | The principal ID of the system-assigned managed identity |
| event_subscription_ids | Map of event subscription IDs |
| event_subscription_names | Map of event subscription names |

## Why AzAPI?

This module uses the AzAPI provider to provide:
- ✅ **Latest Azure Features** - Access to newest Event Grid capabilities
- ✅ **Preview APIs** - Use preview features before GA
- ✅ **Future-Proof** - Always up-to-date with Azure API changes
- ✅ **Flexibility** - Direct Azure REST API access
- ✅ **Advanced Scenarios** - Support for complex configurations

## Examples of System Topic Types

### Storage Account Blob Events
- `Microsoft.Storage.BlobCreated`
- `Microsoft.Storage.BlobDeleted`
- `Microsoft.Storage.BlobRenamed`

### Key Vault Events
- `Microsoft.KeyVault.SecretNewVersionCreated`
- `Microsoft.KeyVault.SecretNearExpiry`
- `Microsoft.KeyVault.CertificateExpired`

### Container Registry Events
- `Microsoft.ContainerRegistry.ImagePushed`
- `Microsoft.ContainerRegistry.ImageDeleted`
- `Microsoft.ContainerRegistry.ChartPushed`

## Best Practices

1. **Naming Convention**: Use consistent naming like `evgt-<source>-<environment>`
2. **Tags**: Always include Environment, ManagedBy, and Owner tags
3. **Identity**: Use System Assigned for simplicity, User Assigned for cross-resource scenarios
4. **Locks**: Apply `CanNotDelete` lock for production resources
5. **Diagnostics**: Enable diagnostic settings for monitoring and compliance
6. **RBAC**: Follow principle of least privilege for role assignments

## Troubleshooting

### Common Issues

1. **Topic Type Mismatch**: Ensure the `topic_type` matches the `source_arm_resource_id` resource type
2. **Identity Requirements**: Some event sources require managed identity for certain event types
3. **Region Availability**: Verify Event Grid System Topics are available in your region
4. **Permissions**: Ensure you have `EventGrid Contributor` or `Owner` permissions

## Contributing

This module follows Azure Verified Module (AVM) guidelines.

## License

MIT License

## Authors

Created and maintained by Platform Engineering Team
