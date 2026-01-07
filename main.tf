# Create the Event Grid System Topic using the AzAPI provider and the 2023-12-15-preview API version
resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.EventGrid/systemTopics@2023-12-15-preview"
  body = {
    properties = {
      source    = var.source_arm_resource_id
      topicType = var.topic_type
    }
    identity = var.identity != null ? {
      type = var.identity.type
      userAssignedIdentities = var.identity.type != "SystemAssigned" && var.identity.identity_ids != null ? {
        for id in var.identity.identity_ids : id => {}
      } : null
    } : null
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  lifecycle {
    ignore_changes = [
      tags["created_date"],
      tags["created_by"]
    ]
  }
}

# Diagnostic settings for the System Topic
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = coalesce(each.value.name, "${var.name}-diag-${each.key}")
  target_resource_id             = azapi_resource.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = length(each.value.log_categories) > 0 ? each.value.log_categories : []

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_metric" {
    for_each = length(each.value.metric_categories) > 0 ? each.value.metric_categories : []

    content {
      category = enabled_metric.value
    }
  }

  lifecycle {
    ignore_changes = [
      # Azure API doesn't return log_analytics_destination_type in response
      # causing perpetual drift - ignore changes to prevent this
      log_analytics_destination_type
    ]
  }
}

# required AVM resources interfaces (scoped to the created system topic)
resource "azurerm_management_lock" "this" {
  count = var.locks != null ? 1 : 0

  lock_level = var.locks.kind
  name       = coalesce(var.locks.name, "lock-${var.locks.kind}")
  scope      = azapi_resource.this.id
  notes      = var.locks.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
