public class AccountTriggerHandler {
 
    public static void associateAccountwithContact(List<Account> accRecords){
        List<Contact> conList=new List<Contact>();
        for(Account acc:accRecords){
            Contact con = new Contact(LastName=acc.Name+'assosiated', AccountId= acc.Id);
            conList.add(con);
        }
        insert conList;
    }
    
    //when an account is updated with industry as banking create a contact
    public static void createContactWhenAccountisUpdated(List<Account> newAccounts, Map<Id, Account> oldaccountMap){
        system.debug('createContactWhenAccountisUpdated');
        try{
            List<Contact> conList=new List<Contact>();
            for(Account acc:newAccounts){
                //get the old value of industry field of current from trriger Old
                String tempIndustaryOldValue = oldaccountMap.get(acc.Id).Industry;
                String tempIndustaryNewValue = acc.Industry;
                
                system.debug('createContactWhenAccountisUpdated: tempIndustaryOldValue ' +tempIndustaryOldValue);
                system.debug('createContactWhenAccountisUpdated: tempIndustaryNewValue ' +tempIndustaryNewValue);
                if(acc.Industry.equals('Banking') && !tempIndustaryOldValue.equals(tempIndustaryNewValue)){
                    Contact con= new Contact(LastName=acc.Name+'banking updated', Phone=acc.Phone);
                    conList.add(con);
                }
            }
            insert conList;
        }catch(Exception e){
            system.debug('error'+e);
        }
        
    }
    //when an account is created with industry as banking create a contact
    public static void createContactWhenAccountisCreated(List<Account> triggerNew){
        try{
            List<Contact> conList=new List<Contact>();
            for(Account acc:triggerNew){
                
                if(acc.Industry.equals('Banking')){
                    Contact con = new Contact(LastName=acc.Name+'banking created', Phone=acc.Phone);
                    conList.add(con);
                }
                if(acc.NumberofLocations__c > 0){
                    createContactsWhenAccountisCreated((Integer)acc.NumberofLocations__c,acc);
                }
            }
            upsert conList;
        }catch(Exception e){
            system.debug('error'+e);
        }
        
    }
    
    //create n number of contacts when account is created
    private static void createContactsWhenAccountisCreated(Integer counter, Account acc){
        List<Contact> conList=new List<Contact>();
        system.debug('counter: '+counter);
        for(Integer i=0 ; i<counter ; i++){
            Contact con=new Contact();
            system.debug('account id'+acc.Id);
            con.AccountId=acc.Id;
            con.LastName=acc.Name + (i+1);
            conList.add(con);
        }
    	system.debug('Contacts List: ' +conList);
    	insert conList;
    }
    
    //create contact on account delete
    public static void onAccountDelete(List<Account> accList){
        system.debug('delete');
        try{
            List<Contact> conList=new List<Contact>();
            for(Account acc:accList){
               Contact con=new Contact(LastName=acc.Name+'deleted'); 
               conList.add(con);
            }
            insert conList;
        }catch(Exception e){
            system.debug('error'+e);
        }
    }
    
    //when account industry is media poplate rating as hot
    public static void updateIndustryRating(List<Account> accList){
        for(Account acc:accList){
            if(acc.Industry != null && acc.Industry.equals('Media')){
                acc.Rating='Hot';
            }    
        }
    }
    //error delelting record when account rating is hot
    public static void stopDelete(List<Account> accList){
        system.debug('delete if hot');

        List<Profile> adminProfileIDs= [SELECT Name, Id FROM Profile where Name='System Administrator' AND Id=:UserInfo.getProfileId()];

        for(Account acc:accList){
            if (adminProfileIDs.size() != 0) { // current user is not admin
                if(acc.Rating.equals('Hot')){
                    acc.addError('you can not perform this operation, ask your admin for help.');
                } 
            }
        }
    }
}