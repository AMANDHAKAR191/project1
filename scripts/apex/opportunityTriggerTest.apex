String testName = 'Test 2';
//create product2
Product2 p = [SELECT Id FROM Product2 LIMIT 1];
System.debug('product: '+p);

// Create test pricebook and pricebook entry
Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
// PricebookEntry standardPricebookEntry = new PricebookEntry(
//     Pricebook2Id = standardPricebook.Id,
//     Product2Id = p.Id, // Replace with actual Product2Id if needed
//     UnitPrice = 60,
//     IsActive = true
// );
// insert standardPricebookEntry;
PricebookEntry standardPricebookEntry = [SELECT Id FROM PricebookEntry where Product2Id = :p.Id];

// Create test account
Account testAccount = new Account(Name = testName+'Account');
insert testAccount;

// Create test opportunities
Opportunity opp1 = new Opportunity(Name = testName+'Opportunity 1', StageName = 'Prospecting', CloseDate = System.today(), AccountId = testAccount.Id);
Opportunity opp2 = new Opportunity(Name = testName+'Opportunity 2', StageName = 'Prospecting', CloseDate = System.today(), AccountId = testAccount.Id);
insert new List<Opportunity>{ opp1, opp2 };

// Create Opportunity Line Items
OpportunityLineItem oli1 = new OpportunityLineItem(
    OpportunityId = opp1.Id,
    PricebookEntryId = standardPricebookEntry.Id, // Specify PricebookEntryId for API version 30.0 and higher
    Quantity = 10,
    TotalPrice=20
);
OpportunityLineItem oli2 = new OpportunityLineItem(
    OpportunityId = opp2.Id,
    PricebookEntryId = standardPricebookEntry.Id, // Specify PricebookEntryId for API version 30.0 and higher
    Quantity = 20,
    TotalPrice=20
);
insert new List<OpportunityLineItem>{ oli1, oli2 };

// Test the updateAccountField method
OpportunityTriggerHandler.updateAccountField1(new List<Opportunity>{ opp1, opp2 });

// Retrieve the updated account to verify changes
Account updatedAccount = [SELECT total_Opportunity_Products__c FROM Account WHERE Id = :testAccount.Id];
System.debug('total product count: '+ updatedAccount.total_Opportunity_Products__c);
