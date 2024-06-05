public with sharing class OpportunityApiHelper {
    public static Map<String, Object> createOppotunity(RestRequest request){
        Map<String, Object> jsonResponse = new Map<String, Object>();
        String requestBody = request.requestBody.toString();
        Map<String, Object> data =  (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        //get data from request from client
        String name=(String) data.get('name');
        String stageName=(String) data.get('stageName');
        String closeDate=(String) data.get('closeDate');
        
        System.debug('name: '+name+'stageName: '+stageName+'closeDate'+closeDate);
        // data validation which we go in request and performed required operations.
        try{
            if(!checkPicklistValue(stageName)){
                jsonResponse.put('status', false);
                jsonResponse.put('ERROR', 'Given Stage Name is not valid');
            }else{
                Opportunity opp=new Opportunity(Name=name,StageName=stageName,CloseDate=Date.parse(closeDate));
                Database.SaveResult saveResult=Database.insert(opp, AccessLevel.USER_MODE);
                // system.debug('USER');
                // insert as user opp;
                jsonResponse.put('status', true);
                jsonResponse.put('message', 'OPPORTUNITY CREATED');
                System.debug('saveResult.id: '+saveResult.getId());
                jsonResponse.put('Id', saveResult.getId());
                if (!saveResult.isSuccess()) {
                    System.debug('sr.errors: '+saveResult.getErrors());
                }
            }
        }catch(System.TypeException type){
            jsonResponse.put('status', false);
            jsonResponse.put('ERROR', 'Invalid Date Format');
        }catch(System.DmlException dml){
            jsonResponse.put('status', false);
            jsonResponse.put('ERROR', 'REQUIRED FIELD MISSING');
        }
        System.debug('jsonResponse: '+jsonResponse);
        return jsonResponse;
    }
    public static Map<String, Object> getOpportunity(RestRequest request){
        Map <String, String> data = request.params;
        Map<String, Object> jsonResponse = new Map<String, Object>();
        try{
            // Opportunity.sObjectType.getDescribe().isAccessible()
            String oppId= data.get('Id');
            if (oppId == null) {
                jsonResponse.put('status', false);
                jsonResponse.put('ERROR','Invalid Opportunity Id');
            }else {
                Opportunity oppData=[SELECT Id,Name from Opportunity where Id=:oppId LIMIT 1];
                jsonResponse.put('Id', oppData.Id);
                jsonResponse.put('Name',oppData.Name);
                jsonResponse.put('status', true);
            }
        }catch(System.QueryException qe){
            jsonResponse.put('status', false);
            jsonResponse.put('ERROR', 'Invalid Opportunity Id');
        }
        return jsonResponse;
    }
    public static Map<String, Object> editOpportunity(RestRequest request){
        String requestBody=request.requestBody.toString();
        Map<String, String> params = request.params;
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        Map<String, Object> jsonResponse = new Map<String, Object>();

        try{
            // Opportunity.sObjectType.getDescribe().isUpdateable()
            String oppId=params.get('Id');
            System.debug('oppId: '+oppId);
            if (oppId == null) {
                jsonResponse.put('status', false);
                jsonResponse.put('ERROR','Invalid Opportunity Id');
            }else {
                String oppName=(String)data.get('name');
                Opportunity oppData=[SELECT Id,Name,stageName,CloseDate FROM Opportunity WHERE Id=:oppId];
                System.debug('oppData: '+oppData);
                String message= 'Opportunity Name Updated from [' +oppData.Name+ '] to [' + oppName+ '] for Id: ' +oppId;
                if(oppName.equals(oppData.Name)){
                    jsonResponse.put('status', false);
                    jsonResponse.put('ERROR','No data changed');
                }else{
                    oppData.Name=oppName;
                    Database.SaveResult saveResult= Database.update(oppData, AccessLevel.USER_MODE);
                    jsonResponse.put('status', true);
                    jsonResponse.put('message',message);
                }
            }
        }catch(System.QueryException qe){
            jsonResponse.put('status', false);
            jsonResponse.put('ERROR','Invalid Opportunity Id');
        }
        return jsonResponse;
    }
    public static Map<String, Object> deleteOpportunity(RestRequest request){
        Map<String, String> params = request.params;
        Map<String, Object> jsonResponse = new Map<String, Object>();
        try {
            // Opportunity.sObjectType.getDescribe().isDeletable()
            String oppId = params.get('Id');
            if (oppId == null) {
                jsonResponse.put('status', false);
                jsonResponse.put('ERROR','Invalid Opportunity Id');
            }else {
                Database.delete(Id.valueOf(oppId), AccessLevel.USER_MODE);
                jsonResponse.put('status', true);
                jsonResponse.put('message', 'Opportunity record deleted');
            }
        }catch(System.StringException se){
            jsonResponse.put('status', false);
            jsonResponse.put('ERROR','Invalid Opportunity Id');
        }
        return jsonResponse;
    }
    //this method is for check validating the stageName picklist value
    private static boolean checkPicklistValue(String tempStageName){
        Schema.DescribeFieldResult objFieldDescribe=Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> objPicklistValues = objFieldDescribe.getPicklistValues();
        system.debug('tempStageName:' +tempStageName);
        Set<String> stageNameSet = new Set<String>();
        for (Schema.PicklistEntry entry : objPicklistValues) {
            system.debug('entry' +entry.getValue());
            stageNameSet.add(entry.getValue());
        }

        if(stageNameSet.contains(tempStageName)){
            system.debug('stageNameSet contains ' +tempStageName);
            return true;
        }
        return false;
    }
}