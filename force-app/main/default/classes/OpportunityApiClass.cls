@RestResource(urlMapping='/Opportunity/create/')
global class OpportunityApiClass {
    
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String requestBody = request.requestBody.toString();
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        Map<String, Object> jsonResponse = new Map<String,Object>();

        String name = (String) data.get('Name');
        String stageName = (String) data.get('StageName');
        // Date closeDate = Date.today().addDays(5);
        String dateString = (String) data.get('CloseDate');
        
        if(name.equals('') || stageName.equals('') || dateString.equals('')){
            jsonResponse.put('status', false);
            jsonResponse.put('message', 'REQUIRED FIELD MISSING');
        }else {
            CreateOpportunityQueue createOpp = new CreateOpportunityQueue(name, stageName, dateString);
            Id jobId = System.enqueueJob(createOpp);
            jsonResponse.put('status', true);
            jsonResponse.put('message', 'opportunity create job created successfully');
            AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobId];
            System.debug('jobInfo: '+jobInfo);
            jsonResponse.put('jobInfo', jobInfo);
            // jsonResponse.put('id', saveResult.getId());
            // jsonResponse.put('op', op);
        }
        response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
        response.addHeader('Content-Type', 'application/json');
    }
    @HttpGet
    global static void doGet(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String requestBody = request.requestBody.toString();
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        Map<String, Object> jsonResponse = new Map<String,Object>();
        
        String queueJobId = (String) data.get('jobId');
        if(queueJobId.equals('')){
            jsonResponse.put('status', false);
            jsonResponse.put('message', 'Job Id is null');
        }else {
            jsonResponse.put('status', true);
            // jsonResponse.put('message', '');
            AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:queueJobId];
            System.debug('jobInfo: '+jobInfo);
            jsonResponse.put('jobInfo', jobInfo);
        }
        response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
        response.addHeader('Content-Type', 'application/json');
    }
}