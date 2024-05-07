List<Case> caseList = new List<Case>();
Case c = new Case(AccountId = '001F900001keGCHIA2', Origin = 'Phone', AOD__c = 5.0, Subject='vs code testing1');
caseList.add(c);
//List<Case> caseList = new List<Case>();
Case c1 = new Case(AccountId = '001F900001keGakIAE', Origin = 'Phone', AOD__c = 100.0, Subject='vs code testing2');
caseList.add(c1);
insert caseList; 
