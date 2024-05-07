public with sharing class CaseTriggerHandler {
    public static void preventUserToCreateCase(List<Case> newCases){
        System.debug('newCases: '+ newCases);
        if (newCases != null) {
            System.debug('preventUserToCreateCase');
            // Set<String> accountIds = new Set<String>();
            Map<String,Case> customCaseMapData = new Map<String,Case>();
            for (Case c : newCases) {
                // accountIds.add(c.AccountId);
                customCaseMapData.put(c.AccountId, c);
            }
            List<String> accountIds = new List<String>(customCaseMapData.keySet());
            //get total AOD from account
            List<Account> accountList = [select Id, total_AOD__c from Account where Id in :accountIds];
            Map<String,Decimal> customAccountMapData = new Map<String,Decimal>();
            for (Account acc : accountList) {
                System.debug('tempAccount: '+acc);
                customAccountMapData.put(acc.Id, acc.Total_AOD__c);
            }
            List<Case> caseList = [SELECT Id,AccountId, AOD__C FROM Case where AccountId in :accountIds And AOD__c != null];
            System.debug('customCaseMapData: '+customCaseMapData);
            System.debug('accountIds: '+accountIds);

            for (String tempAccountId : customCaseMapData.keySet()) {
                Decimal coutAOD = 0;
                for (Case tempCase : caseList) {
                    if (tempCase.AccountId == tempAccountId) {
                        coutAOD += tempCase.AOD__c;
                    }
                }
                coutAOD += customCaseMapData.get(tempAccountId).AOD__c;
                System.debug('AOD: '+coutAOD);
                System.debug('total AOD: '+customAccountMapData.get(tempAccountId));
                if (coutAOD > customAccountMapData.get(tempAccountId)) {
                    System.debug('AOD is > then 100');
                    System.debug('AOD should be less then '+customAccountMapData.get(tempAccountId));
                    customCaseMapData.get(tempAccountId).addError('AOD ('+coutAOD+') should be less then totalAOD('+customAccountMapData.get(tempAccountId)+')');
                }else {
                    System.debug('AOD is < then 100');
                }
            }
        }
    }
}