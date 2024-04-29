/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */
public with sharing class AccountTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        Logger.debug('Account Trigger: before insert');
    }

    public override void afterInsert() {
        Logger.debug('Account Trigger: after insert');
    }
}
