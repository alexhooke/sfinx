/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */
@RestResource(urlMapping='/contacts/*')
global with sharing class ContactWebService {

    @HttpPost
    global static String createContactWithAccount(String contactName, String companyName) {
        try {

            // Search for an existing Account based on the provided company name
            Account acc = [SELECT Name FROM Account WHERE Name = :companyName LIMIT 1];

            // Create a new Contact
            Contact person = new Contact();
            person.FirstName = contactName.split(' ')[0];
            person.LastName = contactName.split(' ')[1];
            person.AccountId = acc.Id; // Link the Contact to the existing Account

            // Insert the Contact
            insert person;

            return 'Contact created successfully with Id: ' + person.Id;

        } catch (Exception e) {
            Logger.log(e);
        }

        return 'exit';
    }
}
