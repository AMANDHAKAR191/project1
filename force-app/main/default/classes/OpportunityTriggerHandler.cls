public with sharing class OpportunityTriggerHandler {
    public static void updateAccountField(List<Opportunity> newOpportunities){
        List<Account> accountsTOUpdate = new List<Account>();
            for (Opportunity op : newOpportunities) {
                List<AggregateResult> productCount =  [SELECT SUM(Quantity) FROM OpportunityLineItem WHERE Opportunity.AccountId = :op.AccountId];
                System.debug('productCount: '+productCount);
                System.debug('productCount: '+productCount.get(0).get('expr0'));
                Account accountTOUpdate = new Account();
                accountTOUpdate.Id = op.AccountId;
                accountTOUpdate.total_Opportunity_Products__c =(Decimal) productCount.get(0).get('expr0');
                accountsTOUpdate.add(accountTOUpdate);
            }
            update accountsTOUpdate;
    }

    public static void updateAccountField1(List<Opportunity> newOpportunities) {
        if (newOpportunities.isEmpty()) {
            return;
        }

        // Gather all Opportunity Ids
        // Set<Id> opportunityIds = new Set<Id>();
        Map<Id, Id> oppIdToAccountId = new Map<Id, Id>();
        for (Opportunity op : newOpportunities) {
            // opportunityIds.add(op.Id);
            oppIdToAccountId.put(op.Id, op.AccountId);
        }

        // Query OpportunityLineItems linked to these Opportunity Ids
        List<OpportunityLineItem> lineItems = [
            SELECT OpportunityId, Quantity
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIdToAccountId.keySet()
        ];
        System.debug('lineItems: '+lineItems);

        // Aggregate total quantities per Account
        Map<Id, Decimal> accountQuantities = new Map<Id, Decimal>();
        for (OpportunityLineItem oli : lineItems) {
            Id accountId = oppIdToAccountId.get(oli.OpportunityId);
            if (accountId != null) {
                if (!accountQuantities.containsKey(accountId)) {
                    accountQuantities.put(accountId, oli.Quantity);
                } else {
                    accountQuantities.put(accountId, accountQuantities.get(accountId) + oli.Quantity);
                }
            }
        }

        // Prepare and update Account records
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountQuantities.keySet()) {
            Account accountToUpdate = new Account(Id = accountId, total_Opportunity_Products__c = accountQuantities.get(accountId));
            accountsToUpdate.add(accountToUpdate);
        }

        update accountsToUpdate;
    }
}