trigger temp on Patient (before insert) {
    // Map<String, Patent__c> patentsToAssign = new Map<String Patent__c>();
    // for(Patent p : trigger.new){
    //     patentIds.put(p.Id, p);
    // }
    List<Doctor__c> freeDoctors = [select id from Doctor__c where id not in (select docotrId from Patent__c)]; 
    
    for(Patent p: trigger.new){

    }

    if (freeDoctors.size()<0) {
        
        
    }
}