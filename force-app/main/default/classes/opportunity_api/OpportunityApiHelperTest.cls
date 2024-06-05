@isTest
private class OpportunityApiHelperTest {

    private static User createTestUser(){
        // // Create a unique UserName
        // String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // // This code runs as the system user
        // Profile p = [SELECT Id FROM Profile WHERE Name='AmanDhakar Profile'];
        // User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        // EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        // LocaleSidKey='en_US', ProfileId = p.Id,
        // TimeZoneSidKey='America/Los_Angeles',
        // UserName=uniqueUserName);
        User u = [select Id from User where UserName='kirandhaker123@gmail.com'];
        return u;

    }

    // Helper method to create a test request
    private static RestRequest createMockRequestForCreateOpportunity(String name, String stageName, String closeDate) {
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('name', name);
        requestBody.put('stageName', stageName);
        requestBody.put('closeDate', closeDate);

        String jsonString = JSON.serialize(requestBody);
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonString);
        return req;
    }
    // Helper method to create a test request
    private static RestRequest createMockRequestForEditOpportunity(String name, String oppId) {
        RestRequest req = new RestRequest();
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('name', name);
            String jsonString = JSON.serialize(requestBody);
            req.addParameter('Id', oppId);
            req.requestBody = Blob.valueOf(jsonString);
        return req;
    }
    // Helper method to create a test request
    private static RestRequest createMockRequestForGetOpportunity(String oppId) {
        RestRequest req = new RestRequest();
            Map<String, Object> requestBody = new Map<String, Object>();
            String jsonString = JSON.serialize(requestBody);
            req.addParameter('Id', oppId);
            req.requestBody = Blob.valueOf(jsonString);
        return req;
    }
    // Helper method to create a test request
    private static RestRequest createMockRequestForDeleteOpportunity(String oppId) {
        RestRequest req = new RestRequest();
            Map<String, Object> requestBody = new Map<String, Object>();
            String jsonString = JSON.serialize(requestBody);
            req.addParameter('Id', oppId);
            req.requestBody = Blob.valueOf(jsonString);
        return req;
    }

    //for create
    @isTest
    static void testCreateOpportunitySuccess() {
        String name = 'test name';
        String stageName = 'Closed Won';
        String closeDate = '25/04/2024';
        RestRequest req = createMockRequestForCreateOpportunity(name, stageName, closeDate);
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.createOppotunity(req);
        Test.stopTest();
        Assert.areEqual(true, response.get('status'));
        Assert.areEqual('OPPORTUNITY CREATED', response.get('message'));
        // Assert.isNotNull(response.get('Id'));
    }
    //for einstein test
    // @isTest
    // static void testCreateOpportunitySuccessDummy() {
       
    // }
    // @isTest
    // static void testCreateOpportunitySuccessForGuestUser() {
    //     String name = 'test name';
    //     String stageName = 'Closed Won';
    //     String closeDate = '25/04/2024';
    //     RestRequest req = createMockRequestForCreateOpportunity(name, stageName, closeDate);
    //     System.runAs(createTestUser()){
    //         Test.startTest();
    //         Map<String, Object> response = OpportunityApiHelper.createOppotunity(req);
    //         Test.stopTest();
    //         Assert.areEqual(false, response.get('status'));
    //         Assert.areEqual('Insufficient Permissions to create opportunity', response.get('ERROR'));
    //     }
    // }
    @isTest
    static void testCreateOpportunityInvalidStageName() {
        String name = 'test name';
        String stageName = 'Closed';
        String closeDate = '25/04/2024';
        RestRequest req = createMockRequestForCreateOpportunity(name, stageName, closeDate);
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.createOppotunity(req);
        Test.stopTest();
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('Given Stage Name is not valid', response.get('ERROR'));
    }
    @IsTest
    static void testCreateOpportunityMissingRequiredFields() {
        String name = 'Test Opp';
        String stageName = 'Prospecting';
        String closeDate = '23/04/2435';
        RestRequest req = createMockRequestForCreateOpportunity(null, stageName, closeDate);
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.createOppotunity(req);
        Test.stopTest();
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('REQUIRED FIELD MISSING', response.get('ERROR'));        
    }
    @IsTest
    static void testCreateOpportunityNullValues() {
        String name = '';
        String stageName = 'Prospecting';
        String closeDate = '23/04/2435';
        RestRequest req = createMockRequestForCreateOpportunity(name, stageName, closeDate);
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.createOppotunity(req);
        Test.stopTest();
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('REQUIRED FIELD MISSING', response.get('ERROR'));        
    }
    @IsTest
    static void testCreateOpportunityInvalidDateFormat() {
        String name = 'Test Opp';
        String stageName = 'Prospecting';
        String closeDate = '23-04-2435';
        RestRequest req = createMockRequestForCreateOpportunity(name, stageName, closeDate);
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.createOppotunity(req);
        Test.stopTest();
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('Invalid Date Format', response.get('ERROR'));        
    }
    // for edit

    @isTest
    static void testEditOpportunitySuccess() {
        String name = 'test name';
        Opportunity opp = new Opportunity(Name = 'old opp', StageName='Closed Won', CloseDate=Date.parse('23/05/2024'));
        Database.SaveResult sr = Database.insert(opp);
        RestRequest req = createMockRequestForEditOpportunity(name, sr.getId());
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.editOpportunity(req);
        Test.stopTest();
        Assert.areEqual(true, response.get('status'));
        Assert.isNotNull(response.get('message'));
    }
    // @isTest
    // static void testEditOpportunitySuccessForGuestUser() {
    //     String name = 'test name';
    //     Opportunity opp = new Opportunity(Name = 'old opp', StageName='Closed Won', CloseDate=Date.parse('23/05/2024'));
    //     Database.SaveResult sr = Database.insert(opp);
    //     RestRequest req = createMockRequestForEditOpportunity(name, sr.getId());
    //     System.runAs(createTestUser()){
    //         Test.startTest();
    //         Map<String, Object> response = OpportunityApiHelper.editOpportunity(req);
    //         Test.stopTest();
    //         Assert.areEqual(false, response.get('status'));
    //         Assert.areEqual('Insufficient Permissions to edit opportunity', response.get('ERROR'));
    //     }
    // }

    @isTest
    static void testEditOpportunityNoDataChanged() {
        String name = 'old opp';
        Opportunity opp = new Opportunity(Name = 'old opp', StageName='Closed Won', CloseDate=Date.parse('23/05/2024'));
        Database.SaveResult sr = Database.insert(opp);
        RestRequest req = createMockRequestForEditOpportunity(name, sr.getId());
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.editOpportunity(req);
        Test.stopTest();
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('No data changed', response.get('ERROR'));
    }
    @isTest
    static void testEditOpportunityNoIdProvided() {
        String name = 'test opp data';
        RestRequest req = createMockRequestForEditOpportunity(name, null);
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.editOpportunity(req);
        Test.stopTest();
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('Invalid Opportunity Id', response.get('ERROR'));
    }
    @isTest
    static void testEditOpportunityInvalidOpportunityId() {
        String name = 'test opp data';
        RestRequest req = createMockRequestForEditOpportunity(name, 'kjsdfhsdkjfhdsk3453');
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.editOpportunity(req);
        Test.stopTest();
        System.debug('status: '+ response.get('status'));
        System.debug('ERROR: '+ response.get('ERROR'));
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('Invalid Opportunity Id', response.get('ERROR'));
    }

    // for get
    @isTest
    static void testGetOpportunitySuccess() {
        Opportunity opp = new Opportunity(Name = 'old opp', StageName='Closed Won', CloseDate=Date.parse('23/05/2024'));
        Database.SaveResult sr = Database.insert(opp);
        RestRequest req = createMockRequestForGetOpportunity(sr.getId());
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.getOpportunity(req);
        Test.stopTest();
        Assert.areEqual(true, response.get('status'));
        Assert.areEqual(opp.Name, response.get('Name'));
    }
    // @isTest
    // static void testGetOpportunitySuccessForGuestUser() {
    //     Opportunity opp = new Opportunity(Name = 'old opp', StageName='Closed Won', CloseDate=Date.parse('23/05/2024'));
    //     Database.SaveResult sr = Database.insert(opp);
    //     RestRequest req = createMockRequestForGetOpportunity(sr.getId());
    //     System.runAs(createTestUser()){
    //         Test.startTest();
    //         Map<String, Object> response = OpportunityApiHelper.getOpportunity(req);
    //         Test.stopTest();
    //         Assert.areEqual(false, response.get('status'));
    //         Assert.areEqual('Insufficient Permissions to read opportunity', response.get('ERROR'));
    //     }
    // }
    @isTest
    static void testGetOpportunityNoIdProvided() {
        RestRequest req = createMockRequestForGetOpportunity(null);
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.getOpportunity(req);
        Test.stopTest();
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('Invalid Opportunity Id', response.get('ERROR'));
    }
    @isTest
    static void testGetOpportunityInvalidOpportunityId() {
        RestRequest req = createMockRequestForGetOpportunity('kjsdfhsdkjfhdsk3453');
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.getOpportunity(req);
        Test.stopTest();
        System.debug('status: '+ response.get('status'));
        System.debug('ERROR: '+ response.get('ERROR'));
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('Invalid Opportunity Id', response.get('ERROR'));
    }

    //for delete
    @isTest
    static void testDeleteOpportunitySuccess() {
        Opportunity opp = new Opportunity(Name = 'old opp', StageName='Closed Won', CloseDate=Date.parse('23/05/2024'));
        Database.SaveResult sr = Database.insert(opp);
        RestRequest req = createMockRequestForGetOpportunity(sr.getId());
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.deleteOpportunity(req);
        Test.stopTest();
        Assert.areEqual(true, response.get('status'));
        Assert.areEqual('Opportunity record deleted', response.get('message'));
    }
    // @isTest
    // static void testDeleteOpportunitySuccessForGuestUser() {
    //     Opportunity opp = new Opportunity(Name = 'old opp', StageName='Closed Won', CloseDate=Date.parse('23/05/2024'));
    //     Database.SaveResult sr = Database.insert(opp);
    //     RestRequest req = createMockRequestForGetOpportunity(sr.getId());
    //     System.runAs(createTestUser()){
    //         Test.startTest();
    //         Map<String, Object> response = OpportunityApiHelper.deleteOpportunity(req);
    //         Test.stopTest();
    //         Assert.areEqual(false, response.get('status'));
    //         Assert.areEqual('Insufficient Permissions to delete opportunity', response.get('ERROR'));
    //     }
    // }
    @isTest
    static void testDeleteOpportunityNoIdProvided() {
        RestRequest req = createMockRequestForDeleteOpportunity(null);
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.deleteOpportunity(req);
        Test.stopTest();
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('Invalid Opportunity Id', response.get('ERROR'));
    }
    @isTest
    static void testDeleteOpportunityInvalidOpportunityId() {
        RestRequest req = createMockRequestForDeleteOpportunity('kjsdfhsdkjfhdsk3453');
        Test.startTest();
        Map<String, Object> response = OpportunityApiHelper.deleteOpportunity(req);
        Test.stopTest();
        System.debug('status: '+ response.get('status'));
        System.debug('ERROR: '+ response.get('ERROR'));
        Assert.areEqual(false, response.get('status'));
        Assert.areEqual('Invalid Opportunity Id', response.get('ERROR'));
    }
}