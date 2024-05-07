public class Customer_NewTriggerHandler {
    public static void handleAfterUpdate(List<Customer_New__c> newCustomers, Map<Id, Customer_New__c> oldCustomerMap) {
        // Prepare a map to associate accounts with their contacts
        Map<Id, String> contactIdToNewDesc = new Map<Id, String>();
        for (Customer_New__c customer : newCustomers) {
            Customer_New__c oldCustomer = oldCustomerMap.get(customer.Id);
            if (customer.Description__c != oldCustomer.Description__c) { // only process if description changed
                contactIdToNewDesc.put(customer.Id, customer.Description__c);
            }
        }

        // Fetch related contacts only if there's something to update
        if (!contactIdToNewDesc.isEmpty()) {
            List<Contact> contactsToUpdate = [SELECT Id, AccountId, Description FROM Contact WHERE AccountId IN :contactIdToNewDesc.keySet()];
            for (Contact con : contactsToUpdate) {
                con.Description = contactIdToNewDesc.get(con.AccountId);
            }
            update contactsToUpdate; // Perform a single DML operation
        }
    }
}