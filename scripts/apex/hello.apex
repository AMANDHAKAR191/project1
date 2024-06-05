Map<Id, Contact> tempMap = new Map<Id,Contact>([select Id, Name,email from Contact limit 10]);
System.debug('tempMap: '+tempMap);
// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// List<Account> accListForCreate = new List<Account>();
// integer batchSize = 50;
// for(integer i = 0; i<batchSize; i++){
//     Account acc = new Account(Name = 'aman bulk testing10');
//     acc.NumberofLocations__c = 10;
//     accListForCreate.add(acc);
// }
// insert accListForCreate;

// List<Account> acclist = [SELECT Id, Industry, Name FROM Account order by CreatedDate desc limit 1];
// List<Account> acclistForUpdate = new List<Account>();

// for(Account acc: acclist){
//     Account newAccount = new Account();
//     System.debug('account from list: '+ acc);
//     newAccount.Id= acc.Id;
//     newAccount.Description = 'aman@xyz.com';
//     newAccount.Industry = 'Banking';
//     acclistForUpdate.add(newAccount);
// }
// System.debug('acclistForUpdate: '+ acclistForUpdate);
// update acclistForUpdate;
