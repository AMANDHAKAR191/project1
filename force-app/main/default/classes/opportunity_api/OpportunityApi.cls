@RestResource(urlMapping='/Opportunity/')
global with sharing class OpportunityApi {

    @HttpPost
    global static void doPost(){
        // Fetch the current user's record based on the ID provided by UserInfo
        User currentUser = [SELECT Id, Username, Email, ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug('currentUser: '+currentUser);
        RestRequest request=RestContext.request;
        RestResponse response=RestContext.response;
        response.responseBody=Blob.valueOf(JSON.serialize(OpportunityApiHelper.createOppotunity(request)));
        response.addHeader('Content-Type', 'application/json');
    }


    @HttpGet
    global static void doGet(){ 
        RestRequest request=RestContext.request;
        RestResponse response=RestContext.response;
        response.responseBody=Blob.valueOf(JSON.serialize(OpportunityApiHelper.getOpportunity(request)));
        response.addHeader('Content-Type', 'application/json');

    }

    @HttpPut
    global static void doPut(){
        RestRequest request=RestContext.request;
        RestResponse response=RestContext.response;
        response.responseBody=Blob.valueOf(JSON.serialize(OpportunityApiHelper.editOpportunity(request)));
        response.addHeader('Content-Type', 'application/json');
    }

    @HttpDelete
    global static void doDelete(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.responseBody = Blob.valueOf(JSON.serialize(OpportunityApiHelper.deleteOpportunity(request)));
        response.addHeader('Content-Type', 'application/json');
    }
}