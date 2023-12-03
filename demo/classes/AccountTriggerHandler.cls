/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */
public with sharing class AccountTriggerHandler extends TriggerHandler {
    private override void beforeInsert() {
        Logger.log('Account Trigger: before insert');
    }

    private override void afterInsert() {
        Logger.log('Account Trigger: after insert');
    }
}
