public with sharing class CustomizablePath {

    @AuraEnabled(cacheable=true)
    public static List<PicklistData> getPicklistValues(String objectApiName, String pickListApiName) {
        List<CustomizablePath__mdt> metadataRecords = [SELECT Label, Object_Api_Name__c, Color__C, Picklist_Value__C FROM CustomizablePath__mdt WHERE Object_Api_Name__c = :objectApiName];
        List<PicklistData> picklistValues = new List<PicklistData>();
        for (CustomizablePath__mdt record : metadataRecords) {
            picklistValues.add(new PicklistData(record.Label, record.Color__c, record.Picklist_Value__c));
        }
        return picklistValues;
    }

    class PicklistData {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String color { get; set; }
        @AuraEnabled
        public String picklistValue { get; set; }
    
        // Constructor
        public PicklistData(String label, String color, String picklistValue) {
            this.label = label;
            this.color = color;
            this.picklistValue = picklistValue;
        }
    }
}

