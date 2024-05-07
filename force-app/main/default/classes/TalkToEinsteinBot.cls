public with sharing class TalkToEinsteinBot {
    // @InvocableMethod(Label='send whatsapp message from bot')
    // public static List<String> sendWhatsappMessageFromBot(List<String> messages) {
    //     System.debug('message: '+ messages);
    //     List<String> results = new List<String>();
    //     results.add('this is the response from apex class to:'+messages[0]);
    //     return results;
    // }

    @InvocableMethod(Label='create new chat user')
    public static List<String> createChatUserAccount(List<ChatUserDTO> chatUsers){
        List<String> results = new List<String>();
        String name = chatUsers[0].firstName + chatUsers[0].lastName;
        String phoneNumber = chatUsers[0].phoneNumber;
        chatUser__c cu = new chatUser__c(Name=name, phoneNumber__c=phoneNumber);
        Database.SaveResult srList = Database.insert(cu);
        System.debug('srlist: '+srList);
        results.add('chat user created id: '+srList.getId());
        return results;
    }
}