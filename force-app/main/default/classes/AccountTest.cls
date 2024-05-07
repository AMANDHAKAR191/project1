@isTest
public class AccountTest {
@isTest
    private static void  testOne(){
     Account acc = new Account(Name = 'Hello', Type='Other');
     insert acc;
     Test.startTest();
acc.Type = 'Prospect';
update acc;
Test.stopTest();

AccountHistory[] ah =  [Select AccountId, Field, OldValue, NewValue from AccountHistory where AccountId = :acc.Id];
System.debug('ACC HIST IS ' + ah);
System.assertEQuals(1, ah.size());   //ASSERTION FAILS              
    }

}