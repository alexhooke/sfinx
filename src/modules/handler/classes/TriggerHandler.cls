/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 *
 * @description Trigger Handler allows to organize logic in different methods depending
 * on a trigger event.
 */
public virtual class TriggerHandler {

    private static final Integer DEFAULT_MAX_RECURSION_LIMIT = 3;

    private static Set<String> disabledHandlers = new Set<String>();
    private static Integer maxRecursionLimit = DEFAULT_MAX_RECURSION_LIMIT;
    private static Integer recursionCount = 0;


    public void run() {
        this.run(Trigger.operationType);
    }

    public void run(System.TriggerOperation operationType) {

        if (
            operationType == System.TriggerOperation.BEFORE_INSERT ||
            operationType == System.TriggerOperation.BEFORE_UPDATE ||
            operationType == System.TriggerOperation.BEFORE_DELETE
        ) {
            recursionCount++;
        }

        // Check that the trigger can be executed
        if (
            this.isNotTriggerExecution() ||
            this.isDisabled() ||
            this.isMaxRecursion()
        ) {
            return;
        }

        // Route Trigger logic
        switch on operationType {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    public static void setMaxRecursion(Integer maxRecursion) {
        maxRecursionLimit = maxRecursion;
    }

    public static Integer getMaxRecursion() {
        return maxRecursionLimit;
    }

    public static void deactivateAll() {
        disabledHandlers.add('*');
    }

    public static void deactivate(String handlerName) {
        disabledHandlers.add(handlerName);
    }

    public static void activate(String handlerName) {
        disabledHandlers.remove(handlerName);
    }

    public static void activateAll() {
        disabledHandlers.clear();
    }

    private Boolean isNotTriggerExecution() {
        return !(Trigger.isExecuting || Test.isRunningTest());
    }

    private Boolean isDisabled() {

        String handlerName = this.getHandlerName();

        if (
            disabledHandlers.contains('*') ||
            disabledHandlers.contains(handlerName)
        ) {
            return true;
        }

        Trigger_Settings__c settings = Trigger_Settings__c.getInstance(handlerName);
        if (settings == null) {
            settings = new Trigger_Settings__c(
                Name = handlerName,
                Is_Enabled__c = true
            );
            insert settings;
        }

        return !settings.Is_Enabled__c;
    }

    private Boolean isMaxRecursion() {
        return recursionCount >= maxRecursionLimit;
    }

    private String getHandlerName() {
        return String.valueOf(this).substringBefore(':');
    }


    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void beforeDelete() {}
    protected virtual void afterInsert() {}
    protected virtual void afterUpdate() {}
    protected virtual void afterDelete() {}
    protected virtual void afterUndelete() {}
}
