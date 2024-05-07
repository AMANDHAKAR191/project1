public with sharing class TriggerHelper {
    /**
     * @return true if changes made and false if no changes made
     */
    // Checks if any field has changed in the record
    public static Boolean hasAnyFieldChanged(SObject newRecord, SObject oldRecord, List<Schema.SObjectField> fieldsToExclude) {
        Map<String, Schema.SObjectField> fieldMap = newRecord.getSObjectType().getDescribe().fields.getMap();
        
        for (String fieldName : fieldMap.keySet()) {
            if (fieldsToExclude != null && fieldsToExclude.contains(fieldMap.get(fieldName))) {
                continue; // Skip this field if it's in the exclude list
            }
            
            if (newRecord.get(fieldMap.get(fieldName)) != oldRecord.get(fieldMap.get(fieldName))) {
                // Using != on purpose here; for more complex objects, .equals() might be more appropriate
                if (String.valueOf(newRecord.get(fieldMap.get(fieldName))) != String.valueOf(oldRecord.get(fieldMap.get(fieldName)))) {
                    System.debug('TriggerHelper.FieldChanged: ');
                    return true; // Found a changed field
                }
            }
        }
        return false; // No changes found
    }
}