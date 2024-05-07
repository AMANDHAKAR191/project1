public with sharing class RandomContactFactory {
    public static List<Contact> randomContactFactory(Integer numberOfContact, String lastName) {
        List<Contact> contactList = new List<Contact>();
        if (numberOfContact <= 0 || lastName.equals('')) {
            return contactList;
        }
        for (Integer i = 0; i < numberOfContact; i++) {
            Contact tempContact = new Contact(LastName = lastName);
            contactList.add(tempContact);
        }
        return contactList;
    }
}