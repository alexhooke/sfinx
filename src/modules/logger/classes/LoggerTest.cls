/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */
@IsTest
private class LoggerTest {

    @IsTest
    static void testLogException() {

        // Code that may throw an exception
        Test.startTest();
        try {
            System.assert(false, 'This is an example exception');
        } catch (Exception e) {
            Logger.log(e);
        }
        Test.stopTest();

        // Add assertions to check if the log record is created
        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(1, logs.size());

        Log__c log = logs[0];
        System.assertEquals(Logger.CONTEXT_CONTROLLER, log.Context__c);
        System.assertEquals(String.valueOf(Logger.LEVEL_FATAL), log.Level__c);
        System.assertEquals('This is an example exception', log.Message__c);
    }

    @IsTest
    static void testLogMessage() {

        Test.startTest();
        Logger.log(Logger.LEVEL_DEBUG, 'Test log message');
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c LIMIT 1000];
        System.assertEquals(1, logs.size());

        Log__c log = logs[0];
        System.assertEquals(Logger.CONTEXT_CONTROLLER, log.Context__c);
        System.assertEquals(String.valueOf(Logger.LEVEL_DEBUG), log.Level__c);
        System.assertEquals('Test log message', log.Message__c);
    }
}
