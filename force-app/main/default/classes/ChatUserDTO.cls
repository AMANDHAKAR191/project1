public with sharing class ChatUserDTO {
    @InvocableVariable(required=true label='first name')
    public String firstName;
    @InvocableVariable(required=true label='last name')
    public String lastName;
    @InvocableVariable(required=true label='phone number')
    public String phoneNumber;
}