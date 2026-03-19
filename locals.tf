# Managed identities configuration
locals {
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      type        = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
      identityIds = length(var.managed_identities.user_assigned_resource_ids) > 0 ? var.managed_identities.user_assigned_resource_ids : null
    } : null
    system_assigned = var.managed_identities.system_assigned ? {
      type = "SystemAssigned"
    } : null
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      type        = "UserAssigned"
      identityIds = var.managed_identities.user_assigned_resource_ids
    } : null
  }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}
