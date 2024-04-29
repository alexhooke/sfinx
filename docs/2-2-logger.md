# Logger


## Logger Settings

If the logger cannot detect the settings, it logs only Error and Fatal level logs.

| Lable | API Name | Default | Description |
| ---- | ---- | ---- | ---- |
| **Enabled** | `Is_Enabled__c` | `true` | Whether logging is enabled for a profile or a user selected in the Location field. |
| Min Log Level | `Min_Log_Level__c` | `0` | Minimum logging level. Numerical value (10 - Debug, 20 - Warning, 30 - Error, 40 - Fatal). |

## Logger Examples

The logger has 3 groups of methods with different signatures

- `debug` methods are intended for recording debug data
- `log` methods allows you to record information at any logging level
- `handle` methods automatically searches for errors in input data