trigger LeadTrigger on Lead (After update) {
    if(trigger.isUpdate && trigger.isAfter){
        // LeadTriggerHandler.afterInsert(trigger.newMap);
        // System.debug('check point leadTrigger');
        Lead lead = new Lead(LastName= 'dhaker', Company='xyzx', Status='Working-Contacted');
        insert lead;
    }

}