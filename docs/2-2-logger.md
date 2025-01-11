# Logger

## Logger Settings

If the logger cannot detect the settings, it logs only Error and Fatal level logs.

| Lable | API Name | Default | Description |
| ---- | ---- | ---- | ---- |
| **Enabled** | `Is_Enabled__c` | `true` | Whether logging is enabled for a profile or a user selected in the Location field. |
| Min Log Level | `Min_Log_Level__c` | `0` | Minimum logging level. Numerical value (10 - Debug, 20 - Warning, 30 - Error, 40 - Fatal). |


## Logger Examples

The logger has 4 main groups of methods with different signatures: debug, error, handle and log.

### Debug Methods

Debugging methods allow logging information with the debug level (`Logger.LEVEL_DEBUG`).

```java
// You can log a message
Logger.debug('Debug message');

// or a message together with debug data
Logger.debug('Debug log with data', new List<String> {
    'The second parameter can be any variable or collection' 
});
```

### Error Methods

The error methods repeat the capabilities of the debug methods but create a `Log__c` object records at the error level (`Logger.LEVEL_ERROR`).

```java
// You can log an error message
Logger.error('Error message');

// or an error message with debug data
Logger.debug('Error log with debug data', apiResponseData);
```

### Handle Methods

Handling methods are designed to automatically handle the most common situations requiring logging. These methods automatically searches for errors in input parameters.

#### Exception handling

The system creates an ERROR level record with detailed information about an Exception that occurred.

```java
try {
    insert contacts;
} catch (Exception e) {
    Logger.handle(e);
}
```


#### Database operations handling

```java
Database.UpsertResult[] upsertResults = Database.upsert(orders);
Logger.log(orders, upsertResults);
```

```java
Database.SavetResult[] upsertResults = Database.upsert(orders);
Logger.log(orders, upsertResults);
```

#### API Requests and Responses handling

```java
// Execute the HTTP request
HttpResponse response = http.send(request);

// Log HTTP request and HTTP response
Logger.handle(request, response);
```

### Log methods


### Log Builder

In situations where the capabilities of predefined logger methods are not enough, you can use the builder to create a Log record with any set of parameters.

```java
Logger
    .getInstnace()
    .setMessage().
    .linkTo()
    .save()
```
