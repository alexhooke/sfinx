/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */
public with sharing class ContactTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        Logger.debug('Contact Trigger: before insert');
    }

    public override void afterInsert() {
        Logger.debug('Contact Trigger: after insert');
    }

    public override void beforeUpdate() {
        Logger.debug('Contact Trigger: before update');
    }

    public override void afterUpdate() {
        Logger.debug('Contact Trigger: after update');
    }
}
