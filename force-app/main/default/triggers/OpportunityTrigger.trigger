trigger OpportunityTrigger on Opportunity (before update) {
    System.debug('OPP updated');
    switch on trigger.OperationType {
        when BEFORE_UPDATE {
            OpportunityTriggerHandler.updateAccountField1(trigger.new);
        }
    }
}