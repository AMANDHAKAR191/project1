/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class FirstClass_Test {

    @isTest
    static void myMethod() {
         // Create test data for Customer_New__c
        List<Customer_New__c> testCustomers = new List<Customer_New__c>();
        testCustomers.add(new Customer_New__c(Name = 'Test Customer 1', Customer_New_Type__c = 'A'));
        testCustomers.add(new Customer_New__c(Name = 'Test Customer 2', Customer_New_Type__c = 'B'));
        testCustomers.add(new Customer_New__c(Name = 'Test Customer 3', Customer_New_Type__c = 'C'));
        insert testCustomers;
        
        // Call the method to be tested
        Test.startTest();
        FirstClass.myMethod();
        Test.stopTest();
        
        // Retrieve updated records
        List<Customer_New__c> updatedCustomers = [SELECT Name, Customer_New_Type__c, Customer_Description__c FROM Customer_New__c];
        
        // Verify that the Customer_Description__c field is updated correctly
        System.assertEquals('A type', updatedCustomers[0].Customer_Description__c, 'Customer description should be "A type" for type "A"');
        System.assertEquals('B type', updatedCustomers[1].Customer_Description__c, 'Customer description should be "B type" for type "B"');
        System.assertEquals('C type', updatedCustomers[2].Customer_Description__c, 'Customer description should be "C type" for type "C"');

    }
}