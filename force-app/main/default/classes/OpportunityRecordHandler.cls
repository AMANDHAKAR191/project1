public with sharing class OpportunityRecordHandler {
    
    @AuraEnabled
    public static string CreateOpportunity(String name, String stageName, String closeDate){
        try {
            Map<String, Object> auraResult = new Map<String, Object>();
            if (!Opportunity.sObjectType.getDescribe().isCreateable()) {
                auraResult.put('status', false);
                auraResult.put('ERROR', 'Insufficient Permissions to create opportunity');
                return JSON.serialize(auraResult);
            }
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:SalesforceLoginNamed/services/apexrest/Opportunity/');
            request.setMethod('POST');
            Map<String,String> jsonRequest = new Map<String,String>();
            jsonRequest.put('name', name);
            jsonRequest.put('stageName', stageName);
            jsonRequest.put('closeDate', closeDate);
            request.setBodyAsBlob(Blob.valueOf(JSON.serializePretty(jsonRequest)));
            System.debug('request: '+request);
            HttpResponse response = new Http().send(request);
            System.debug('response: '+response);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                return responseBody;
            }else {
                auraResult.put('status', false);
                auraResult.put('ERROR', 'helo test test');
                return JSON.serialize(auraResult);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled(Cacheable = True)
    @AuraEnabled()
    public static List<Opportunity> getAllOpportunities(){
        List<Opportunity> opps = new List<Opportunity>();
        try {
            opps = [SELECT Id, Name, CreatedDate FROM Opportunity WHERE CreatedDate = TODAY]; // i want to all opportunities created by this user
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return opps;
    }
}