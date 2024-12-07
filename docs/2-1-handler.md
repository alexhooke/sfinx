# Trigger Framework

## Overview

The **Trigger Framework** simplifies and organizes trigger logic by routing events to dedicated methods within a 
Trigger Handler. This ensures better code maintainability, testability, and adherence to Salesforce best practices.

Each Trigger Handler extends the base `TriggerHandler` class and implements logic for specific events like 
`beforeInsert`, `beforeUpdate`, or `afterDelete`.

## Features

### Event Routing

Trigger logic is executed based on the current trigger event. Supported events include:

- `beforeInsert`
- `beforeUpdate`
- `beforeDelete`
- `afterInsert`
- `afterUpdate`
- `afterDelete`
- `afterUndelete`

### Trigger Activation Management

The framework supports granular control over trigger activation:

1. Custom Settings: The Trigger_Settings__c object manages whether a handler is enabled or disabled globally.
2. Programmatic Control: Handlers can be enabled or disabled within the current execution context.
3. Custom Permission: specific permissions allow users to bypass trigger execution.

### Recursion Control

To prevent infinite loops caused by recursive trigger execution, the framework includes a built-in mechanism to limit recursion.

---

## Quick Start

### Creating a Custom Trigger Handler

To implement a new Trigger Handler:

1.	Create a class that extends the TriggerHandler base class.
2.	Override the necessary methods corresponding to the trigger events you want to handle.
3.	Add the logic specific to your business requirements within these methods.

**Example: Account Trigger Handler**

Below is an example of a Trigger Handler for the Account object that handles the beforeInsert event.

```java
public with sharing class AccountTriggerHandler extends TriggerHandler {

    // Override the beforeInsert method to add custom logic
    public override void beforeInsert() {
        // Add custom logic here
    }
}
```

### Associating the Trigger Handler with a Trigger

Once the Trigger Handler is implemented, invoke it from the corresponding trigger. This ensures that the logic defined in the handler is executed when the trigger events occur.

**Example: Account Trigger**

```java
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AccountTriggerHandler().run();
}
```

---

## Managing Trigger Activation

The run() method provided by the TriggerHandler base class orchestrates the execution of the overridden methods 
based on the context of the trigger event. This ensures clean and maintainable code by separating the logic for 
each trigger event into dedicated methods within the handler class.

**1. Custom Settings**

The `Trigger_Settings__c` object manages global activation. A record is automatically created for each handler with
`Is_Enabled__c` set to true by default. Uncheck `Is_Enabled__c` to disable the handler globally.

**2. Programmatic Control**

Handlers can be enabled or disabled dynamically during runtime, affecting only the current execution context:

- Deactivate all trigger handlers: `TriggerHandler.deactivateAll()`
- Deactivate a specific trigger handler: `TriggerHandler.deactivate('HandlerName')`
- Activate all trigger handlers: `TriggerHandler.activateAll()`
- Activate a specific handler: `TriggerHandler.activate('HandlerName')`

**3. Custom Permissions**

Custom Permissions provide an additional layer of flexibility by allowing specific users to bypass trigger 
execution, either partially or entirely:

- Bypass Automation: Skips all automation processes, including Triggers, Flows, Process Builder, and Workflow 
Rules. Use this permission for scenarios where a user needs to bypass all automated processes for testing or 
special data updates.

- Bypass Triggers: Skips only trigger logic, allowing other automation processes (e.g., Flows or Workflow Rules) 
to execute as usual. This is ideal for users who need to bypass triggers without disrupting other automation.


> [!WARNING]
> 
> The framework ensures **Bypass Automation** is respected only within Trigger Handlers. Developers using the 
framework are responsible for ensuring that Flows, Process Builder, and other custom logic respect this 
permission as needed. Failure to implement these checks outside of Trigger Handlers may result in unintended 
automation execution.

---

## Recursion Control

### Default Behavior

The framework sets a default recursion limit to prevent triggers from executing indefinitely. By default, this 
limit is 3 executions.

### Customizing Recursion Limits

You can adjust the recursion limit programmatically using:

```java
TriggerHandler.setMaxRecursion(Integer maxRecursion);
Integer currentLimit = TriggerHandler.getMaxRecursion();
```

```java
TriggerHandler.setMaxRecursion(5); // Set the recursion limit to 5
```


## Best Practices

- **One Trigger Per Object**: Use a single trigger per object and leverage the framework to handle multiple events within that trigger for better organization and maintainability.
- **Bulkification**: Ensure all trigger handlers are designed to handle bulk operations efficiently to avoid governor limits.
- **Minimize Recursive Calls**: Use the built-in recursion control to prevent infinite loops and maintain optimal performance.
- **Handle Governor Limits**: Avoid SOQL/DML operations inside loops and optimize your logic to stay within Salesforce limits.
- **Restrict Bypass Permissions**: Assign Bypass Automation and Bypass Triggers sparingly to trusted users only and document their usage to prevent misuse.
- **Check Bypass Automation in Other Automations**: Ensure Flows, Process Builder, and custom logic include checks for the Bypass Automation permission if required, as the framework enforces this only within Trigger Handlers.