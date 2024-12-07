/**
 * (c) Alexander Hooke <alexander.hooke@gmail.com>
 *
 * This file is part of the SFINX package. For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 *
 * @description Trigger Handler allows to organize logic in different methods depending
 * on a trigger event.
 */
public inherited sharing virtual class TriggerHandler {

    private static final Integer DEFAULT_MAX_RECURSION_LIMIT = 3;

    private static Set<String> disabledHandlers = new Set<String>();
    private static Integer maxRecursionLimit = DEFAULT_MAX_RECURSION_LIMIT;
    private static Integer recursionCount = 0;


    /**
     * @description Executes the handler logic based on the current trigger operation type.
     */
    public void run() {
        this.run(Trigger.operationType);
    }

    /**
     * @description Executes the handler logic for the specified trigger operation type.
     *
     * @param operationType The trigger operation type (e.g., BEFORE_INSERT, AFTER_UPDATE).
     */
    public void run(System.TriggerOperation operationType) {

        if (isBeforeEvent(operationType)) {
            recursionCount++;
        }

        if (shouldSkipExecution()) {
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

    /**
     * @description Sets the maximum recursion limit for the trigger handler.
     *
     * @param maxRecursion The maximum number of recursions allowed.
     */
    public static void setMaxRecursion(Integer maxRecursion) {
        maxRecursionLimit = maxRecursion;
    }

    /**
     * @description Gets the maximum recursion limit for the trigger handler.
     *
     * @return The maximum recursion limit.
     */
    public static Integer getMaxRecursion() {
        return maxRecursionLimit;
    }

    /**
     * @description Disables all trigger handlers.
     */
    public static void deactivateAll() {
        disabledHandlers.add('*');
    }

    /**
     * @description Disables a specific trigger handler by class name.
     *
     * @param handlerName The name of the handler to deactivate.
     */
    public static void deactivate(String handlerName) {
        disabledHandlers.add(handlerName);
    }

    /**
     * @description Activates a specific trigger handler by name.
     *
     * @param handlerName The name of the handler class to activate.
     */
    public static void activate(String handlerName) {
        disabledHandlers.remove(handlerName);
    }


    /**
     * @description Activates all trigger handlers globally.
     */
    public static void activateAll() {
        disabledHandlers.clear();
    }

    /**
     * @description Determines if the operation type is a before-event.
     *
     * @param operationType The operation type to evaluate.
     * @return True if the operation is a before-event; false otherwise.
     */
    private Boolean isBeforeEvent(System.TriggerOperation operationType) {
        return operationType == System.TriggerOperation.BEFORE_INSERT ||
               operationType == System.TriggerOperation.BEFORE_UPDATE ||
               operationType == System.TriggerOperation.BEFORE_DELETE;
    }

    /**
     * @description Determines if the trigger execution should be skipped.
     *
     * @return True if execution should be skipped; false otherwise.
     */
    private Boolean shouldSkipExecution() {
        return isNotTriggerExecution() || isDisabled() || hasBypassPermission() || isMaxRecursion();
    }

    /**
     * @description Checks if the current execution is outside the trigger or test context.
     *
     * @return True if not executing within a trigger or test; false otherwise.
     */
    private Boolean isNotTriggerExecution() {
        return !(Trigger.isExecuting || Test.isRunningTest());
    }

    /**
     * @description Checks if the handler is disabled globally or by custom settings.
     * 
     * @return True if the handler is disabled; false otherwise.
     */
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
            Database.insert(settings, false, AccessLevel.SYSTEM_MODE);
        }

        return !settings.Is_Enabled__c;
    }

    /**
     * @description Checks if the user has permissions to bypass automation or triggers.
     *
     * @return True if the user has bypass permissions; false otherwise.
     */
    private Boolean hasBypassPermission() {
        return FeatureManagement.checkPermission('Bypass_Automation') ||
               FeatureManagement.checkPermission('Bypass_Triggers');
    }

    /**
     * @description Checks if the maximum recursion limit has been reached.
     *
     * @return True if the maximum recursion limit is reached; false otherwise.
     */
    private Boolean isMaxRecursion() {
        return recursionCount >= maxRecursionLimit;
    }

    /**
     * @description Gets the name of the current trigger handler.
     *
     * @return The name of the trigger handler.
     */
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
