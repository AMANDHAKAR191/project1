trigger Customer_NewTrigger on Customer_New__c (before update, after update) {
    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            // Pre-processing before accounts are updated
        }
        if (Trigger.isAfter) {
            // Post-processing after accounts are updated
            Customer_NewTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}