public with sharing class testComponantApexClass {
    @AuraEnabled(cacheable = true)
    public static List<Contact>  getContactAll(){
        List<Contact> contactList = new List<Contact>();
        try {
            contactList = [SELECT FirstName, LastName FROM Contact limit 100];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contactList;
    }

    @AuraEnabled
    public static void updateContacts(List<Contact> contacts) {
        // Perform update DML operation
        update contacts;
    }
}