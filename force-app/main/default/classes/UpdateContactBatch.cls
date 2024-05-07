global class UpdateContactBatch implements Database.Batchable<SObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Title FROM Contact]);
    }

    global void execute(Database.BatchableContext bc, List<Contact> cList){
        for (Contact c : cList) {
            c.Title = 'This is updated from batch class';
        }
        update cList;
    }  
    global void finish(Database.BatchableContext bc){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'amandhaker191@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch task completed!!');
        mail.setPlainTextBody('Contacts are updated using batch class');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
    global void execute(SchedulableContext sc){
        UpdateContactBatch ucb = new UpdateContactBatch();
        Database.executeBatch(ucb);
    }
}