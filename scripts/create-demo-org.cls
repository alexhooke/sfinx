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
