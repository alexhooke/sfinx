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

    public enum Context {ANONYMOUS, API, BATCH, APEX_TRIGGER, UI, UNIT_TEST, OTHER}

    public static final Integer DEFAULT_MIN_LOG_LEVEL  = 30;

    public static final Integer LEVEL_DEBUG    = 10;
    public static final Integer LEVEL_INFO     = 20;
    public static final Integer LEVEL_WARNING  = 30;
    public static final Integer LEVEL_ERROR    = 40;
    public static final Integer LEVEL_CRITICAL = 50;

    private static final String SOBJECT_POSTFIX_EVENT  = '__e';


    /**
     * @description Logging a debug message
     * 
     * @param message Debug message
     * @return Id of the created log record
     */
    public static Id debug(String message) {
        return log(LEVEL_DEBUG, message);
    }

    /**
     * @description Logging a debug message with debug data
     * 
     * @param message Debug message
     * @param o Debug data (variable or collection)
     * @return Id of the created log record
     */
    public static Id debug(String message, Object o) {
        return log(LEVEL_DEBUG, message, o);
    }

    /**
     * @description Logging an error
     * 
     * @param message Error message
     * @return Id of the created log record
     */
    public static Id error(String message) {
        return log(LEVEL_ERROR, message);
    }

    /**
     * @description Logging an error with debug data
     * 
     * @param message Error message
     * @param o Debug data (variable or collection)
     * @return Id of the created log record
     */
    public static Id error(String message, Object o) {
        return log(LEVEL_ERROR, message, o);
    }

    /**
     * @description Handling exceptional situations
     *
     * @param e Exception
     * @return Id of the created log record
     */
    public static Id handle(Exception e) {
        return log(LEVEL_ERROR, e, null);
    }

    /**
     * @description Handling a Database insert or update result
     *
     * @param records List of records that were passed to Database.insert or Database.update methods
     * @param saveResults Result of executing Database.insert or Database.update
     * @return Id of the created log record
     */
    public static Id handle(SObject[] records, Database.SaveResult[] saveResults) {

        List<Database.Error> errors = new List<Database.Error>();
        for (Database.SaveResult saveResult: saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error error: saveResult.getErrors()) {
                    errors.add(error);
                }
            }
        }

        if (errors.size() > 0) {
            return log(records, errors);
        }

        return null;
    }

    /**
     * @description Handling a Database upsert result
     *
     * @param records List of records that were passed to Database.upsert method
     * @param upsertResults Result of executing Database.upsert
     * @return Id of the created log record
     */
    public static Id handle(SObject[] records, Database.UpsertResult[] upsertResults) {

        List<Database.Error> errors = new List<Database.Error>();
        for (Database.UpsertResult upsertResult: upsertResults) {
            if (!upsertResult.isSuccess()) {
                for (Database.Error error: upsertResult.getErrors()) {
                    errors.add(error);
                }
            }
        }

        if (errors.size() > 0) {
            return log(records, errors);
        }

        return null;
    }

    /**
     * @description Logging a text message with the specified logging level
     *
     * @param logLevel Numerical logging level (the higher the level, the more serious a log)
     * @param message Log message
     * @return Id of the created log record
     */
    public static Id log(Integer logLevel, String message) {
        return log(logLevel, message, null);
    }

    /**
     * @description Logging a text message with related data and the specified logging level
     *
     * @param logLevel Numerical logging level (the higher the level, the more serious a log)
     * @param message Log message
     * @param o Debug data (variable or collection)
     * @return Id of the created log record
     */
    public static Id log(Integer logLevel, String message, Object o) {
        return getInstance()
            .setLogLevel(logLevel)
            .setMessage(message)
            .setDebugData(o)
            .save();
    }

    /**
     * @description Main logging method
     *
     * @param logLevel Numerical logging level (the higher the level, the more serious a log).
     * @param e Exception
     * @param o Debug data (variable or collection)
     * @return Id of the created log record
     */
    public static Id log(Integer logLevel, Exception e, Object o) {
        return getInstance()
            .setException(e)
            .setDebugData(o)
            .save();
    }

    /**
     * @description Logging a Database errors
     *
     * @param records List of records that were passed to Database methods
     * @param errors List of database erros
     * @return Id of the created log record
     */
    private static Id log(SObject[] records, Database.Error[] errors) {
        return getInstance()
            .setLogLevel(LEVEL_ERROR)
            .setMessage('Database Result')
            .setDebugData(errors)
            .setTriggerNewRecords(records)
            .save();
    }

    /**
     * @description Returns a new instance of the Log class.
     *
     * @return A new instance of Log
     */
    public static Log getInstance() {
        return new Log();
    }


    public inherited sharing class Log { // NOPMD

        private Log__c log = new Log__c();
        private Exception e;


        /**
         * @description Sets exception information in the log.
         *
         * @param e Exception to be logged
         * @return The current instance of Log
         */
        public Log setException(Exception e) {

            this.e = e;

            log.Level__c       = getNonEmpty(log.Level__c, LEVEL_ERROR);
            log.Message__c     = getNonEmpty(log.Message__c, e.getMessage());
            log.Stack_Trace__c = getNonEmpty(log.Stack_Trace__c, e.getStackTraceString());
            log.Apex_Class__c  = getNonEmpty(log.Apex_Class__c, getApexClassFromStackTrace(log.Stack_Trace__c));

            if (!e.getTypeName().equals(LoggerException.class.getName())) {
                // Removing the prefix for system exceptions
                String exceptionName = e.getTypeName();
                if (exceptionName.startsWith('System.')) {
                    exceptionName = exceptionName.substring(7);
                }
                log.Exception_Type__c = exceptionName;
            }

            if (e instanceof DmlException) {
                if (String.isEmpty(log.Record_Id__c)) {
                    // TODO: Should be list of records
                    this.linkTo( e.getDmlId(0));
                }
            }

            return this;
        }

        /**
         * @description Sets debug data in the log
         *
         * @param o Object to be logged
         * @return The current instance of Log
         */
        public Log setDebugData(Object o) {
            if (o instanceof String) {
                log.Debug_Data__c = (String)o;
            } else {
                log.Debug_Data__c = serialize(o);
            }
            return this;
        }

        /**
         * @description Sets log level in the log
         *
         * @param logLevel Log level
         * @return The current instance of Log
         */
        public Log setLogLevel(Integer logLevel) {

            log.Level__c = String.valueOf(logLevel);

            return this;
        }

        /**
         * @description Sets a message in the log.
         *
         * @param message Text message to be logged
         * @return The current instance of Log
         */
        public Log setMessage(String message) {

            log.Message__c = message;

            return this;
        }

        /**
         * @description Sets list of records for new trigger context
         * @param records List of records
         * @return The current instance of Log
         */
        public Log setTriggerNewRecords(SObject[] records) {

            Set<String> triggerObjects = new Set<String>();
            Set<String> triggerIds = new Set<String>();

            for (SObject record: records) {
                String SObjectName = record.getSObjectType().getDescribe().getName();
                triggerObjects.add(SObjectName);
                if (!SObjectName.endsWith(SOBJECT_POSTFIX_EVENT)) {
                    triggerIds.add(record.Id);
                }
            }

            log.Trigger_New_Records__c = serialize(Trigger.new);
            log.Trigger_Size__c = records.size();
            log.Trigger_Object__c = String.join(triggerObjects, ', ');

            if (triggerIds.size() == 1 && !log.Trigger_Object__c.endsWith(SOBJECT_POSTFIX_EVENT)) {
                log.Record_Id__c = triggerIds.iterator().next();
            }

            return this;
        }

        /**
         * @description Links the log to a specific record.
         *
         * @param recordId Record ID to link
         * @return The current instance of Log
         */
        public Log linkTo(Id recordId) {
            return linkTo(new List<Id>{recordId});
        }

        /**
         * @description Links the log to multiple records.
         *
         * @param recordIds List of record IDs to link
         * @return The current instance of Log
         */
        public Log linkTo(Id[] recordIds) {

            log.Related_Records__c = serialize(recordIds);

            return this;
        }


        /**
         * @description Saving the log to the database.
         *
         * @return Log record id (or null if a record wasn't created)
         */
        public Id save() {

            log.Level__c = getNonEmpty(log.Level__c, LEVEL_DEBUG);

            if (isLoggingNotAllowed(Integer.valueOf(log.Level__c))) return null;

            if (this.e == null) {
                this.setException(new LoggerException(log.Message__c));
            }

            // Set Execution information
            Request request = Request.getCurrent();
            log.Request_Id__c = getNonEmpty(log.Request_Id__c, request.getRequestId());
            log.Execution_Context__c = getNonEmpty(log.Execution_Context__c, request.getQuiddity().name());
            log.Logger_Context__c = getNonEmpty(log.Logger_Context__c, this.getContext(request.getQuiddity()));
            log.Log_Time__c = DateTime.now().formatGMT('HH:mm:ss.SSS');

            // Set Trigger Context information
            if (Trigger.isExecuting) {
                log.Trigger_Operation__c   = getNonEmpty(log.Trigger_Operation__c, Trigger.operationType.name());
                log.Trigger_Size__c        = Decimal.valueOf(getNonEmpty(log.Trigger_Size__c, Trigger.size));
                log.Trigger_Old_Records__c = getNonEmpty(log.Trigger_Old_Records__c, serialize(Trigger.old));

                if (String.isEmpty(log.Trigger_New_Records__c)) {
                    this.setTriggerNewRecords(Trigger.new);
                }
            }

            // Trimming values of long fields
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation = true;
            log.setOptions(dml);

            Database.insert(log, false, AccessLevel.SYSTEM_MODE);

            return log.Id;
        }

        /**
         * @description A helper method that determines whether the given log can be logged.
         *
         * @param logLevel Numerical logging level (the higher the level, the more serious a log).
         *
         * @return True if logging for this level is not allowed
         */
        private Boolean isLoggingNotAllowed(Integer logLevel) {

            Logger_Settings__c settings = Logger_Settings__c.getInstance();

            // Check if custom settings exist and logging is enabled, and if the log level is above the minimum allowed
            if (settings != null && settings.Is_Enabled__c && settings.Min_Log_Level__c <= logLevel) {
                return false;
            }

            // If no custom settings exist or logging is disabled, check against the default minimum log level
            return DEFAULT_MIN_LOG_LEVEL > logLevel;
        }

        /*
         * @description The method retrieves the first class name from the stack trace string
         *
         * @param stackTrace
         *
         * @return Apex class name
         */
        private String getApexClassFromStackTrace(String stackTrace) {
            Pattern pattern = Pattern.compile('Class\\.([a-zA-Z0-9_]+)');
            Matcher matcher = pattern.matcher(stackTrace);

            if (matcher.find()) {
                return matcher.group(1);
            }

            return null;
        }

        /**
         * @description Defines the context of Apex code execution
         *
         * @return Context name
         */
        private Context getContext(Quiddity quiddity) {

            Set<System.Quiddity> apiQuiddities = new Set<System.Quiddity>{
                System.Quiddity.BULK_API,
                System.Quiddity.COMMERCE_INTEGRATION,
                System.Quiddity.EXTERNAL_SERVICE_CALLBACK,
                System.Quiddity.REST,
                System.Quiddity.SOAP
            };

            Set<System.Quiddity> batchQuiddities = new Set<System.Quiddity>{
                System.Quiddity.BATCH_ACS,
                System.Quiddity.BATCH_APEX,
                System.Quiddity.BATCH_CHUNK_PARALLEL,
                System.Quiddity.BATCH_CHUNK_SERIAL
            };

            Set<System.Quiddity> uiQuiddities = new Set<System.Quiddity>{
                System.Quiddity.AURA,
                System.Quiddity.SYNCHRONOUS,
                System.Quiddity.VF
            };

            // Determine context
            if (Trigger.isExecuting) {
                return Context.APEX_TRIGGER;
            } else if (quiddity == System.Quiddity.ANONYMOUS) {
                return Context.ANONYMOUS;
            } else if (apiQuiddities.contains(quiddity)) {
                return Context.API;
            } else if (batchQuiddities.contains(quiddity)) {
                return Context.BATCH;
            } else if (uiQuiddities.contains(quiddity)) {
                return Context.UI;
            } else if (Test.isRunningTest()) {
                return Context.UNIT_TEST;
            }

            return Context.OTHER;
        }

        /**
         * @description Returns the first value if it is not empty; otherwise, returns the second value.
         *
         * @param firstValue the primary value to check
         * @param secondValue the fallback value to return if the first value is empty
         *
         * @return the first value if it is not empty, otherwise the second value
         */
        private String getNonEmpty(Object firstValue, Object secondValue) {
            if (String.isNotEmpty(String.valueOf(firstValue))) {
                return String.valueOf(firstValue);
            } else {
                return String.valueOf(secondValue);
            }
        }

        /**
         * @description Converts data into formatted JSON
         *
         * @param data Any data for sterilization
         *
         * @return Formatted JSON
         */
        private String serialize(Object data) {

            if (data == null) {
                return null;
            }

            return JSON.serializePretty(data, true);
        }
    }

    private class LoggerException extends Exception {

        public override String getStackTraceString() {
    
            String[] stackTraceLines = new List<String>();

            for (String line: super.getStackTraceString().split('\n')) {
                if (!line.startsWith('Class.Logger')) {
                    stackTraceLines.add(line);
                }
            }

            return String.join(stackTraceLines, '\n');
        }
    }
}
