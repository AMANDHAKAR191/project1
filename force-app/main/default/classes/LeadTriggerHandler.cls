public class LeadTriggerHandler {
    public static void afterInsert(Map<Id, Lead> leadNewMap){
        System.debug('Check point LeadTriggerHandler.afterInsert');
    }
}