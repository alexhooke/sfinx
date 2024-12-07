// Setup admin user info
User admin = [
    SELECT Id
    FROM User
    WHERE Alias = 'UUser'
];

admin.FirstName = 'James';
admin.LastName = 'Morris';
admin.Alias = 'JMorris';
admin.Department = 'IT';
update admin;

// Activate logger
List<Logger_Settings__c> globalSettings = [
    SELECT Id 
    FROM Logger_Settings__c 
    WHERE SetupOwnerId = :UserInfo.getOrganizationId()
];

if (globalSettings.isEmpty()) {
    Logger_Settings__c globalSetting = new Logger_Settings__c();
    globalSetting.SetupOwnerId = UserInfo.getOrganizationId();
    insert globalSetting;
}
