@RestResource(urlMapping='/CreateContact/')
global class TestApiClass {

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String requestBody = request.requestBody.toString();
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        Map<String, Object> jsonResponse = new Map<String, Object>();

        String lastName = (String) data.get('Last Name');
        if (lastName == null) {
            response.statusCode = 400; // Bad Request
            jsonResponse.put('success', false);
            jsonResponse.put('message', 'Last Name is required');
        } else {
            try {
                Contact contact = new Contact(LastName=lastName);
                insert contact;

                // Set success response
                jsonResponse.put('success', true);
                jsonResponse.put('message', 'Contact created successfully');
                jsonResponse.put('contactId', contact.Id);
            } catch (Exception e) {
                // Handle exceptions and set failure response
                response.statusCode = 500; // Internal Server Error
                jsonResponse.put('success', false);
                jsonResponse.put('error', 'Error creating contact');
                jsonResponse.put('message', e.getMessage());
            }
        }

        response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
        response.addHeader('Content-Type', 'application/json');
    }

    @HTTPGet
    global static void doGet(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Map<String, Object> jsonResponse = new Map<String, Object>();
        try {
                List<Contact> contactList = [SELECT FirstName, LastName FROM Contact];

                // Set success response
                jsonResponse.put('success', true);
                jsonResponse.put('message', 'Contact created successfully');
                jsonResponse.put('contacts', contactList);
            } catch (Exception e) {
                // Handle exceptions and set failure response
                response.statusCode = 500; // Internal Server Error
                jsonResponse.put('success', false);
                jsonResponse.put('error', 'Error creating contact');
                jsonResponse.put('message', e.getMessage());
            }
        response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
        response.addHeader('Content-Type', 'application/json');
    }
}