public with sharing class ObjectUpdateHandler {
    /**
     * get boolean value from custom setting
     * 
     * @return is_Active boolean that refer if transation is runing first time or not.
     */
    @AuraEnabled
    public static Boolean getCustomSetting() {
        // Dhakar_Setting__c setting = Dhakar_Setting__c.getInstance('isFieldChanged');
        String query = 'SELECT is_Active__c FROM Dhakar_Setting__c';
        List<SObject> result = Database.query(query);
        Boolean is_Active = (Boolean) result[0].get('is_Active__c');
        System.debug('getCustomSetting - is_Active: ' + is_Active);
        return is_Active;
    }
    /**
     * set boolean value in custom setting
     * 
     * @param is_Active boolean value
     * 
     * @return is_Active boolean that refer if transation is runing first time or not.
     * @throws Exception throwing an exception or handling the case where no instance is found.
     */
    @AuraEnabled
    public static void setCustomSetting(Boolean is_Active) {
        try {
            System.debug('setCustomSetting - is_Active: ' + is_Active);
            Dhakar_Setting__c setting = Dhakar_Setting__c.getInstance('isFieldChanged');
            if (setting != null) {
                setting.is_Active__c = is_Active;
                upsert setting;
                System.debug('setCustomSetting - Updated is_Active: ' + setting.is_Active__c);
            } else {
                System.debug('setCustomSetting - No instance found to update for Dhakar_Setting__c');
                // Consider throwing an exception or handling the case where no instance is found.
            }
        } catch (Exception e) {
            System.debug('setCustomSetting - Error: ' + e.getMessage());
            throw new AuraHandledException('Error updating setting: ' + e.getMessage());
        }
    }

    /**
     * Processes the transaction based on the provided result and updates the Case record accordingly.
     * 
     * @param recordId The Id of the Case record being processed.
     * @param result A boolean indicating the result of the transaction.
     * 
     * @return A String message indicating the outcome of the transaction processing.
     * 
     * @throws QueryException if there are errors encountered while querying the CaseHistory or Case records.
     * @throws DmlException if there are errors encountered during the update operation on the Case record.
     */
    @AuraEnabled
    // public static String transactionController(String recordId,Boolean result, String ObjectApiName, String UpdatedFieldName){
    public static String revertRecordUpdate(String recordId,Boolean result, String objectApiName, List<String> changedFields){
        changedFields.remove(changedFields.indexOf('LastModifiedDate'));
        System.debug('changedFields: '+changedFields);
        System.debug('revertRecordUpdate: result: '+result);
        //check if recordId (String) is null
        if (recordId == null) {
            return 'No recordId Provided';
        }
        if (result) {
            // process forward
            return 'Case Updated.';
        }else {
            System.debug('objectApiName: '+ objectApiName);
            //dynamically generate historyObjectName and parentId
            String historyObjectName;
            String parentRecordIdLabel;
            if (objectApiName.endsWith('__c')) {
                historyObjectName = objectApiName.replace('__c', '__History');
                parentRecordIdLabel = 'ParentId';
            } else {
                historyObjectName = objectApiName+'History';
                parentRecordIdLabel = objectApiName+'Id';
            }

            String temp = 'field tracking history: ' + objectApiName + 'History';
            System.debug('historyObjectName: '+ historyObjectName);

            //create dynamic query to get field history
            String recordHistoryQuery = 'SELECT OldValue, Id, Field, ' + parentRecordIdLabel + ' FROM ' + historyObjectName + ' WHERE ' + parentRecordIdLabel+' = ' +'\''+ recordId +'\'' + ' ORDER BY CreatedDate DESC LIMIT '+changedFields.size();
            system.debug('query: '+recordHistoryQuery);
            List<SObject> fieldHistoryRecords = Database.query(recordHistoryQuery);
            system.debug('reocrds: '+fieldHistoryRecords.toString());

            MatchResultDTO matchResult = findMatches(changedFields, fieldHistoryRecords, parentRecordIdLabel);
            if (!matchResult.matchStatus) {
                return 'Field History tracking is not enabled for'+matchResult.notTrackedField;
            }
            //create dynamic query to get all the records whose is available in history.
            String recordQuery = 'SELECT ';
            for (FieldHistoryDTO fieldHistory : matchResult.fieldHistory) {
                if (matchResult.fieldHistory.indexOf(fieldHistory) == matchResult.fieldHistory.size()-1) {
                    recordQuery += fieldHistory.fieldApiName;
                }else {
                    recordQuery += fieldHistory.fieldApiName + ', ';
                }
            }
            recordQuery += ' FROM ' + objectApiName + ' WHERE id = ' +'\''+ matchResult.fieldHistory.get(0).parentRecordId +'\'' + ' ORDER BY CreatedDate LIMIT 1';
            system.debug('recordQuery : '+recordQuery);
            SObject recordData =  Database.query(recordQuery);
            system.debug('recordData : '+recordData);

            for (FieldHistoryDTO fieldHistory : matchResult.fieldHistory) {
                recordData.put(fieldHistory.fieldApiName, fieldHistory.oldvalue);
            }
            system.debug('recordDataReverted : '+recordData);
            update recordData;
            //revert the transaction
            return 'case updated is reverted';
        }
    }

    /**
     * Compare changed fields list and historyRecords list  
     * 
     * @param changedFields list of fields that has been changed (got from change data capture)
     * @param records list of SObject records return from SObject field history. 
     * @param parentRecordIdLabel label of id of parent object record in history reocrd.
     * 
     * @return MatchResultDTO data model class which contains matched fields info  
     */
    public static MatchResultDTO findMatches(List<String> changedFields, List<SObject> records, String parentRecordIdLabel){
        List<Boolean> matchingStatus = new List<Boolean>();
        Map<String, FieldHistoryDTO> tempRecords = new Map<String,FieldHistoryDTO>();
        System.debug('parentRecordIdLabel: '+ parentRecordIdLabel);

        //creating map to store neccessory data from history (in FieldHistoryDTO data model class) 
        //with respect to field name as key for easy access
        for (SObject record : records) {
            FieldHistoryDTO fieldHistoryAll = new FieldHistoryDTO();
            String fieldApiName = (String) record.get('Field');
            String oldValue = (String) record.get('OldValue');
            String parentRecordIdValue = (String) record.get(parentRecordIdLabel);
            System.debug('parentRecordIdLabel: '+ parentRecordIdValue);
            fieldHistoryAll.fieldApiName = fieldApiName;
            fieldHistoryAll.parentRecordId = parentRecordIdValue;
            fieldHistoryAll.oldvalue = oldValue;
            tempRecords.put(fieldApiName, fieldHistoryAll);
        }
        System.debug('tempRecords: '+tempRecords);
        MatchResultDTO matchedRecordsResult = new MatchResultDTO();
        List<FieldHistoryDTO> fieldHistoryList = new List<FieldHistoryDTO>();
        List<String> notTrackedFieldList = new List<String>();
        for (String changedField : changedFields) {
            if (tempRecords.keySet().contains(changedField)) {
                FieldHistoryDTO fieldHistory = new FieldHistoryDTO();
                fieldHistory.fieldApiName = changedField;
                fieldHistory.parentRecordId = tempRecords.get(changedField).parentRecordId;
                fieldHistory.oldvalue = tempRecords.get(changedField).oldvalue;
                fieldHistoryList.add(fieldHistory);
                matchingStatus.add(true);
            }else {
                matchingStatus.add(false);
                notTrackedFieldList.add(changedField);
            }
        }
        System.debug('fieldHistoryList: '+fieldHistoryList);
        if (matchingStatus.contains(false)) { //match not found
            matchedRecordsResult.matchStatus = false;
            matchedRecordsResult.notTrackedField = notTrackedFieldList;//null
            matchedRecordsResult.fieldHistory = fieldHistoryList;
            return matchedRecordsResult;
        }else{ //match found
            matchedRecordsResult.matchStatus = true;
            matchedRecordsResult.notTrackedField = notTrackedFieldList;
            matchedRecordsResult.fieldHistory = fieldHistoryList; //null
            return matchedRecordsResult;
        }
    }
}