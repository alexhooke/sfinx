/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 * 
 * @description Logger is designed to save information about various situations for monitoring, 
 * debugging, and auditing purposes
 */
public inherited sharing class Logger {

    public static final Integer DEFAULT_MIN_LOG_LEVEL  = 30;

    public static final Integer LEVEL_DEBUG    = 10;
    public static final Integer LEVEL_INFO     = 20;
    public static final Integer LEVEL_WARNING  = 30;
    public static final Integer LEVEL_ERROR    = 40;
    public static final Integer LEVEL_CRITICAL = 50;

    public static final String CONTEXT_ANONYMOUS         = 'anonymous';
    public static final String CONTEXT_BATCH             = 'batch';
    public static final String CONTEXT_CONTROLLER        = 'controller';
    public static final String CONTEXT_FUNCTION_CALLBACK = 'function-callback';
    public static final String CONTEXT_FUTURE            = 'future';
    public static final String CONTEXT_INTEGRATION       = 'integration';
    public static final String CONTEXT_QUEUEABLE         = 'queueable';
    public static final String CONTEXT_TRIGGER           = 'trigger';
    public static final String CONTEXT_SCHEDULER         = 'scheduler';
    public static final String CONTEXT_UNIT_TEST         = 'unit-test';

    private static final String SOBJECT_POSTFIX_CUSTOM = '__c';
    private static final String SOBJECT_POSTFIX_EVENT  = '__e';


    /**
     * @description Logging textual debugging information.
     * 
     * @param message Debug message
     */
    public static void debug(String message) {
        log(LEVEL_DEBUG, new LoggerException(message), null);
    }

    /**
     * @description Logging textual debugging information with related data.
     * 
     * @param message Debug message
     * @param o Object instance or collection
     */
    public static void debug(String message, Object o) {
        log(LEVEL_DEBUG, new LoggerException(message), o);
    }

    /**
     * @description Logging an exception.
     *
     * @param e Exception
     */
    public static void log(Exception e) {
        log(LEVEL_ERROR, e, null);
    }

    /**
     * @description Logging a Database insert or update result
     *
     * @param records List of records that were passed to Database.insert or Database.update methods.
     * @param saveResults
     */
    public static void log(SObject[] records, Database.SaveResult[] saveResults) {

        List<Database.Error> errors = new List<Database.Error>();
        for (Database.SaveResult saveResult: saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error error: saveResult.getErrors()) {
                    errors.add(error);
                }
            }
        }

        if (errors.size() > 0) {
            log (records, errors);
        }
    }


    /**
     * @description Logging a Database insert or update result
     *
     * @param records List of records that were passed to Database.upsert method.
     */
    public static void log(SObject[] records, Database.UpsertResult[] upsertResults) {

        List<Database.Error> errors = new List<Database.Error>();
        for (Database.UpsertResult upsertResult: upsertResults) {
            if (!upsertResult.isSuccess()) {
                for (Database.Error error: upsertResult.getErrors()) {
                    errors.add(error);
                }
            }
        }

        if (errors.size() > 0) {
            log (records, errors);
        }
    }

    /**
     * @description Logging a Database errors
     */
    private static void log(SObject[] records, Database.Error[] errors) {

        Log__c log = createLogRecord(
            LEVEL_ERROR,
            new LoggerException('Database Result'),
            errors
        );

        Set<String> triggerObjects = new Set<String>();
        for (SObject record: records) {
            triggerObjects.add(record.getSObjectType().getDescribe().getName());
        }

        log.Trigger_New_Records__c = serialize(records);
        log.Trigger_Size__c = records.size();
        log.Trigger_Object__c = String.join(triggerObjects, ', ');

        insert as system log;
    }

    /**
     * @description Logs exception error along with additional data.
     *
     * @param e Exception
     * @param o Object instance or collection
     */
    public static void log(Exception e, Object o) {
        log(LEVEL_ERROR, e, o);
    }

    /**
     * @description Logs a text string with the specified logging level.
     *
     * @param logLevel Numerical logging level (the higher the level, the more serious a log).
     * @param message Log message
     */
    public static void log(Integer logLevel, String message) {
        log(logLevel, new LoggerException(message), null);
    }

    /**
     * @description Logs a text string with related data and the specified logging level.
     *
     * @param logLevel Numerical logging level (the higher the level, the more serious a log).
     * @param message Log message
     * @param o Object for debugging
     */
    public static void log(Integer logLevel, String message, Object o) {
        log(logLevel, new LoggerException(message), o);
    }

    /**
     * @description Main logging method.
     *
     * @param logLevel Numerical logging level (the higher the level, the more serious a log).
     * @param e Exception
     * @param o Object instance or collection
     */
    public static void log(Integer logLevel, Exception e, Object o) {
        insert as system createLogRecord(logLevel, e, o);
    }

    /**
     * @description Creating an instance of the Log object.
     * 
     * @param logLevel Numerical logging level (the higher the level, the more serious a log).
     * @param e Exception
     * @param o Object instance or collection
     */
    private static Log__c createLogRecord(Integer logLevel, Exception e, Object o) {

        if (isLoggingNotAllowed(logLevel)) return null;

        Log__c log = new Log__c(
            Context__c = getContext(e),
            Level__c = '' + logLevel,
            Message__c = e.getMessage(),
            Stack_Trace__c = e.getStackTraceString(),
            Apex_Class__c = getApexClassFromStackTrace(e.getStackTraceString())
        );

        if (!e.getTypeName().equals(LoggerException.class.getName())) {
            // Removing the prefix for system exceptions
            String exceptionName = e.getTypeName();
            if (exceptionName.startsWith('System.')) {
                exceptionName = exceptionName.substring(7);
            }
            log.Exception_Type__c = exceptionName;
        }

        if (e instanceof DmlException) {
            log.Record_Id__c = e.getDmlId(0);
        }

        // Trigger context
        if (Trigger.isExecuting) {
            log.Trigger_Operation__c = Trigger.operationType.name();
            log.Trigger_Size__c = Trigger.size;
            log.Trigger_New_Records__c = serialize(Trigger.new);
            log.Trigger_Old_Records__c = serialize(Trigger.old);

            // If there is more than one item in trigger data,
            // get the information about an object
            if (Trigger.size > 0) {
                log.Trigger_Object__c = Trigger.new.getSObjectType().getDescribe().getName();
                if (!log.Trigger_Object__c.endsWith(SOBJECT_POSTFIX_EVENT) && Trigger.new[0].Id != null) {
                    log.Record_Id__c = Trigger.new[0].Id;
                }
            }
        }

        log.Debug_Data__c = serialize(o);

        // Trimming values of long fields
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        log.setOptions(dml);

        return log;
    }

    /**
     * @description A helper method that determines whether the given log can be logged.
     *
     * @param logLevel Numerical logging level (the higher the level, the more serious a log).
     *
     * @return True if logging for this level is not allowed
     */
    private static Boolean isLoggingNotAllowed(Integer logLevel) {

        Logger_Settings__c settings = Logger_Settings__c.getInstance();

        // Check if custom settings exist and logging is enabled, and if the log level is above the minimum allowed
        if (settings != null && settings.Is_Enabled__c && settings.Min_Log_Level__c <= logLevel) {
            return false;
        }

        // If no custom settings exist or logging is disabled, check against the default minimum log level
        return DEFAULT_MIN_LOG_LEVEL > logLevel;
    }

    /**
     * @description Defines the context of Apex code execution
     *
     * @param e Exception to define code execution from an anonymous context
     *
     * @return Context name
     */
    private static String getContext(Exception e) {

        if (e.getStackTraceString().startsWith('AnonymousBlock:')) {
            return CONTEXT_ANONYMOUS;
        } else if (System.isBatch()) {
            return CONTEXT_BATCH;
        } else if (System.isFunctionCallback()) {
            return CONTEXT_FUNCTION_CALLBACK;
        } else if (System.isFuture()) {
            return CONTEXT_FUTURE;
        } else if (System.isQueueable()) {
            return CONTEXT_QUEUEABLE;
        } else if (Trigger.isExecuting) {
            return CONTEXT_TRIGGER;
        } else if (System.isScheduled()) {
            return CONTEXT_SCHEDULER;
        } else if (Test.isRunningTest()) {
            return CONTEXT_UNIT_TEST;
        }

        return CONTEXT_CONTROLLER;
    }

    /*
     * @description The method retrieves the first class name from the stack trace string
     *
     * @param stackTrace
     *
     * @return Apex class name
	 */
    private static String getApexClassFromStackTrace(String stackTrace) {
        Pattern pattern = Pattern.compile('Class\\.([a-zA-Z0-9_]+)');
        Matcher matcher = pattern.matcher(stackTrace);

        if (matcher.find()) {
            return matcher.group(1);
        }

        return null;
    }

    /**
     * @description Converts data into formatted JSON
     *
     * @param data Any data for sterilization
     *
     * @return Formatted JSON
     */
    private static String serialize(Object data) {

        if (data == null) {
            return null;
        }

        return JSON.serializePretty(data, true);
    }

    private class LoggerException extends Exception {
        public override String getStackTraceString() {
            String stackTrace = super.getStackTraceString();
            List<String> lines = stackTrace.split('\n');
            if (lines.size() > 1) {
                lines.remove(0);
                stackTrace = String.join(lines, '\n');
            }
            return stackTrace;
        }
    }
}
