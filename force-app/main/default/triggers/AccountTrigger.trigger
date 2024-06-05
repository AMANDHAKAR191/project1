trigger AccountTrigger on Account (before insert,after insert,after update, before delete) {
    switch on trigger.OperationType{
        when BEFORE_INSERT{
            system.debug('checkpoint trigger.isInsert.isBefore');
            AccountTriggerHandler.updateIndustryRating(trigger.new);   
            
        }
        when AFTER_INSERT{
            system.debug('checkpoint trigger.isInsert.isAfter');
                system.debug('checkpoint trigger.isInsert.isAfter.Banking');
                AccountTriggerHandler.createContactWhenAccountisCreated(trigger.new);
            AccountTriggerHandler.associateAccountwithContact(trigger.new);
            AccountTriggerHandler.associateContactsWithExistingAccount(trigger.new, trigger.newMap);
		}
        when AFTER_UPDATE{
            system.debug('checkpoint trigger.isUpdate');
            AccountTriggerHandler.createContactWhenAccountisUpdated(trigger.new,trigger.newMap);
        }
        when BEFORE_DELETE{
        	system.debug('checkpoint trigger.isDelete');
        	AccountTriggerHandler.onAccountDelete(trigger.old);
            AccountTriggerHandler.stopDelete(trigger.old);
        }
    }
}