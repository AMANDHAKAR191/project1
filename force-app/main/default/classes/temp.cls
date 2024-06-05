public with sharing class temp extend Database.Batchable<Sobject> {
  public QueryLocator start(Database.BacthableContext bc){
    return [];
  }  
  public void execute(Database.BatchableContext bc, List<Sobject> records){

  }
  public void finish(Database.BatchableContext bc){
    
  }
}