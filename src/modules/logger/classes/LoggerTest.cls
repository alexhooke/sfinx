/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */
@IsTest
private class LoggerTest {

    @TestSetup
    static void makeData() {
        // Org Default Logger Settings
        insert new Logger_Settings__c(
            Is_Enabled__c = true,
            Min_Log_Level__c = 0
        );
    }

    @IsTest
    static void testDebug() {

        Logger.debug('Debug message');

        // Add assertions to check if the log record is created
        List<Log__c> logs = [SELECT Context__c, Level__c, Message__c FROM Log__c LIMIT 1000];
        Assert.areEqual(1, logs.size());

        Log__c log = logs[0];
        Assert.areEqual(String.valueOf(Logger.LEVEL_DEBUG), log.Level__c);
    }

    @IsTest
    static void testDebugWithObject() {

        Logger.debug('Debug message', new List<String>());

        // Add assertions to check if the log record is created
        List<Log__c> logs = [SELECT Context__c, Level__c, Message__c FROM Log__c LIMIT 1000];
        Assert.areEqual(1, logs.size());

        Log__c log = logs[0];
        Assert.areEqual(String.valueOf(Logger.LEVEL_DEBUG), log.Level__c);
    }

    @IsTest
    static void testDatabaseInsert() {

        Test.startTest();
        SObject[] records = new List<Account>{new Account()};
        Database.SaveResult[] saveResults = Database.insert(records, false);
        Logger.log(records, saveResults);
        Test.stopTest();

        // Add assertions to check if the log record is created
        List<Log__c> logs = [SELECT Context__c, Level__c, Message__c FROM Log__c LIMIT 1000];
        Assert.areEqual(1, logs.size());

        Log__c log = logs[0];
        Assert.areEqual(String.valueOf(Logger.LEVEL_ERROR), log.Level__c);
    }

    @IsTest
    static void testDatabaseUpsert() {

        Test.startTest();
        SObject[] records = new List<Account>{new Account()};
        Database.UpsertResult[] upsertResults = Database.upsert(records, false);
        Logger.log(records, upsertResults);
        Test.stopTest();

        // Add assertions to check if the log record is created
        List<Log__c> logs = [SELECT Context__c, Level__c, Message__c FROM Log__c LIMIT 1000];
        Assert.areEqual(1, logs.size());

        Log__c log = logs[0];
        Assert.areEqual(String.valueOf(Logger.LEVEL_ERROR), log.Level__c);
    }

    @IsTest
    static void testLogException() {

        // Code that may throw an exception
        Test.startTest();
        try {
            insert new Account();
        } catch (Exception e) {
            Logger.log(e);
        }
        Test.stopTest();

        // Add assertions to check if the log record is created
        List<Log__c> logs = [SELECT Context__c, Level__c, Message__c FROM Log__c LIMIT 1000];
        Assert.areEqual(1, logs.size());

        Log__c log = logs[0];
        Assert.areEqual(Logger.CONTEXT_UNIT_TEST, log.Context__c);
        Assert.areEqual(String.valueOf(Logger.LEVEL_ERROR), log.Level__c);
    }
    
    @isTest
    static void testLogExceptionWithObject() {

        Test.startTest();
        try {
            Integer result = 1 / 0;
        } catch (Exception e) {
            Logger.log(e, new Account());
        }
        Test.stopTest();
        
        List<Log__c> logs = [SELECT Context__c, Level__c, Message__c FROM Log__c LIMIT 1000];
        Assert.areEqual(1, logs.size());

        Log__c log = logs[0];
        Assert.areEqual(Logger.CONTEXT_UNIT_TEST, log.Context__c);
        Assert.areEqual(String.valueOf(Logger.LEVEL_ERROR), log.Level__c);
    }

    @IsTest
    static void testLogMessage() {

        Test.startTest();
        Logger.log(Logger.LEVEL_DEBUG, 'Test log message');
        Test.stopTest();

        List<Log__c> logs = [SELECT Context__c, Level__c, Message__c FROM Log__c LIMIT 1000];
        Assert.areEqual(1, logs.size());
    }
}
