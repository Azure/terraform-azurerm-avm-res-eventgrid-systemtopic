variable "destination" {
  type = object({
    endpointType = string
    properties   = any
  })
  description = <<DESCRIPTION
The destination where events are delivered. Must include:
- `endpointType` - The type of endpoint (e.g., WebHook, EventHub, StorageQueue, ServiceBusQueue, ServiceBusTopic, AzureFunction, HybridConnection)
- `properties` - Properties specific to the endpoint type (e.g., resourceId for EventHub)
DESCRIPTION
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the event subscription."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,64}$", var.name))
    error_message = "The name must be between 3 and 64 characters long and can only contain letters, numbers, and hyphens."
  }
}

variable "system_topic_id" {
  type        = string
  description = "The resource ID of the parent EventGrid System Topic."
  nullable    = false
}

variable "dead_letter_destination" {
  type = object({
    endpointType = string
    properties   = any
  })
  default     = null
  description = <<DESCRIPTION
Dead letter destination configuration:
- `endpointType` - Must be StorageBlobDeadLetter
- `properties` - Properties including resourceId and blobContainerName
DESCRIPTION
}

variable "dead_letter_with_resource_identity" {
  type = object({
    identity = object({
      type                 = string
      userAssignedIdentity = optional(string)
    })
    deadLetterDestination = object({
      endpointType = string
      properties   = any
    })
  })
  default     = null
  description = "Dead letter destination with managed identity configuration."
}

variable "delivery_with_resource_identity" {
  type = object({
    identity = object({
      type                 = string
      userAssignedIdentity = optional(string)
    })
    destination = object({
      endpointType = string
      properties   = any
    })
  })
  default     = null
  description = "Delivery destination with managed identity configuration."
}

variable "event_delivery_schema" {
  type        = string
  default     = "EventGridSchema"
  description = "The schema for event delivery. Possible values: EventGridSchema, CloudEventSchemaV1_0, CustomInputSchema."

  validation {
    condition     = contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomInputSchema"], var.event_delivery_schema)
    error_message = "The event_delivery_schema must be one of: EventGridSchema, CloudEventSchemaV1_0, CustomInputSchema."
  }
}

variable "expiration_time_utc" {
  type        = string
  default     = null
  description = "Expiration time for the event subscription in UTC (ISO 8601 format)."
}

variable "filter" {
  type = object({
    subjectBeginsWith               = optional(string)
    subjectEndsWith                 = optional(string)
    includedEventTypes              = optional(list(string))
    isSubjectCaseSensitive          = optional(bool, false)
    advancedFilters                 = optional(list(any), [])
    enableAdvancedFilteringOnArrays = optional(bool, false)
  })
  default     = {}
  description = <<DESCRIPTION
Event filtering options:
- `subjectBeginsWith` - Filter events based on subject prefix
- `subjectEndsWith` - Filter events based on subject suffix
- `includedEventTypes` - List of event types to include
- `isSubjectCaseSensitive` - Whether subject filtering is case sensitive
- `advancedFilters` - Advanced filtering conditions
- `enableAdvancedFilteringOnArrays` - Enable advanced filtering on arrays
DESCRIPTION
}

variable "labels" {
  type        = list(string)
  default     = []
  description = "List of user-defined labels for the event subscription."
}

variable "retry_policy" {
  type = object({
    eventTimeToLiveInMinutes = optional(number, 1440)
    maxDeliveryAttempts      = optional(number, 30)
  })
  default     = {}
  description = <<DESCRIPTION
Retry policy for event delivery:
- `eventTimeToLiveInMinutes` - Time to live for events in minutes (default: 1440)
- `maxDeliveryAttempts` - Maximum delivery attempts (default: 30)
DESCRIPTION
}
