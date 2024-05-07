public class FirstClass {
    public static final Map<String,String> customerType = new Map<String,String>{
        'A'=>'A type',
        'B'=>'B type',
        'C'=>'C type'
    };

    public static void myMethod(){
        List<Customer_New__c> listCustomerNew = [select name from Customer_New__c];
        for (Customer_New__c customer_new : listCustomerNew) {
            System.debug(customer_new.Name);
            System.debug(customer_new.Customer_New_Type__c);
            
            customer_new.Customer_Description__c = customerType.get(customer_new.Customer_New_Type__c);
        }
        update listCustomerNew;
        
    }
}