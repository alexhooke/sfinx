/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */
public with sharing class SandboxBatchClass implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name FROM Account';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {
        try {
            for (Account acc: scope) {
                acc.BillingPostalCode = 'Long Postal Code with a lot of text';
            }
            update scope;
        } catch (Exception e) {
            Logger.log(e);
        }

    }

    public void finish(Database.BatchableContext context) {}
}
