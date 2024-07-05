# Trigger Handler

## Trigger Handler Settings



- One Trigger Per Object: Adheres to best practices by ensuring only one trigger is used per object.

- Ease of Adding New Trigger Actions: New trigger actions can be easily implemented by using the appropriate interface 
and setting up custom metadata. This approach promotes flexibility and ease of modification.

- Bypass Options: Offers multiple ways to bypass trigger actions. This can be done for an entire object or specific 
actions through custom metadata configurations, or programmatically for particular transactions. Useful in scenarios 
like data imports or integrations.

- Recursion Control: Manages the recurrence of record processing, preferring to handle recursion per trigger action 
rather than relying solely on the framework. This allows for more controlled reprocessing when necessary.

- Configurable Action Sequence: The execution sequence of trigger actions is determined and organized via custom 
metadata, allowing for precise control over the process flow.
