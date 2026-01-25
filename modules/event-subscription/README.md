# EventGrid System Topic Event Subscription Submodule

This submodule creates an EventGrid Event Subscription for a System Topic.

## Usage

```hcl
module "event_subscription" {
  source = "../../modules/event-subscription"

  name             = "my-event-subscription"
  system_topic_id  = module.system_topic.resource_id

  destination = {
    endpointType = "WebHook"
    properties = {
      endpointUrl = "https://example.com/webhook"
    }
  }

  filter = {
    includedEventTypes = ["Microsoft.Storage.BlobCreated"]
  }
}
```

## Features

- Support for multiple destination types (WebHook, EventHub, ServiceBus, etc.)
- Event filtering capabilities
- Retry policy configuration
- Dead letter destination support
- Managed identity support for delivery
