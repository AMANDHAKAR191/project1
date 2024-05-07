trigger CaseTrigger on Case (before insert) {
    switch on trigger.OperationType {
        when BEFORE_INSERT {
            System.debug('trigger.new: '+trigger.new);
            CaseTriggerHandler.preventUserToCreateCase(trigger.new);
        }
    }
}