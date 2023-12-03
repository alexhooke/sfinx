/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */
global class Logger {

    global static final Integer MIN_LOG_LEVEL  = 40;

    global static final Integer LEVEL_DEBUG    = 10;
    global static final Integer LEVEL_WARNING  = 20;
    global static final Integer LEVEL_ERROR    = 30;
    global static final Integer LEVEL_FATAL    = 40;

    global static final String CONTEXT_ANONYMOUS         = 'anonymous';
    global static final String CONTEXT_BATCH             = 'batch';
    global static final String CONTEXT_CONTROLLER        = 'controller';
    global static final String CONTEXT_FUNCTION_CALLBACK = 'function-callback';
    global static final String CONTEXT_FUTURE            = 'future';
    global static final String CONTEXT_INTEGRATION       = 'integration';
    global static final String CONTEXT_QUEUEABLE         = 'queueable';
    global static final String CONTEXT_TRIGGER           = 'trigger';
    global static final String CONTEXT_SCHEDULER         = 'scheduler';
    global static final String CONTEXT_UNIT_TEST         = 'unit-test';


    public static void log(Exception e) {
        log(LEVEL_ERROR, e, null);
    }

    public static void log(Exception e, Object o) {
        log(LEVEL_ERROR, e, o);
    }

    public static void log(String message) {
        log(LEVEL_DEBUG, new LoggerException(message), null);
    }

    public static void log(Integer logLevel, String message) {
        log(logLevel, new LoggerException(message), null);
    }

    public static void log(Integer logLevel, Exception e, Object o) {

        if (logLevel < MIN_LOG_LEVEL) return;

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
        }

        log.Debug_Data__c = serialize(o);


        log.Limit_Callouts__c = String.valueOf(Limits.getCallouts()) + '/' + String.valueOf(Limits.getLimitCallouts());
        log.Limit_CPU_Time__c = String.valueOf(Limits.getCpuTime()) + '/' + String.valueOf(Limits.getLimitCpuTime());


        // Trimming values of long fields
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        log.setOptions(dml);

        System.debug(log);

        insert log;

        System.debug(log);
    }

    /**
     * Converts data into formatted JSON
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

    /**
     * Defines the context of Apex code execution
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

    public static void clearLogHistory() {
        delete [SELECT Id FROM Log__c ORDER BY CreatedDate LIMIT 10000];
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
