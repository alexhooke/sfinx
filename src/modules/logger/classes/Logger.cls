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
    public static final Integer LEVEL_WARNING  = 20;
    public static final Integer LEVEL_ERROR    = 30;
    public static final Integer LEVEL_FATAL    = 40;

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


    /**
     * @description Logs exception error along with additional data.
     *
     * @param e Exception
     */
    public static void log(Exception e) {
        log(LEVEL_ERROR, e, null);
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
     * @description Logs debug message
     *
     * @param message Debug message
     */
    public static void log(String message) {
        log(LEVEL_DEBUG, new LoggerException(message), null);
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
     * @description Main logging method.
     *
     * @param logLevel Numerical logging level (the higher the level, the more serious a log).
     * @param e Exception
     * @param o Object instance or collection
     */
    public static void log(Integer logLevel, Exception e, Object o) {

        if (isLoggingNotAllowed(logLevel)) return;

        Log__c log = new Log__c(
            Context__c = getContext(e),
            Level__c = '' + logLevel,
            Message__c = e.getMessage(),
            Stack_Trace__c = e.getStackTraceString()
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

            // If there is just one record in a trigger and it has an ID,
            // we associate a log with that record.
            if (Trigger.size == 1 && Trigger.new[0].Id != null) {
                log.Record_Id__c = Trigger.new[0].Id;
            }
        }

        log.Debug_Data__c = serialize(o);

        // Trimming values of long fields
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        log.setOptions(dml);

        insert as system log;
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
