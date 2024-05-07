public class CreateOpportunityQueue implements Queueable {
    String name, stageName, dateString;
    public CreateOpportunityQueue(String name, String stageName, String dateString){
        this.name = name;
        this.stageName = stageName;
        this.dateString = dateString;
    }
    public void execute(QueueableContext context) {
        Opportunity op = new Opportunity(Name=name, StageName = stageName, CloseDate = Date.parse(dateString));
        Database.SaveResult saveResult =  Database.insert(op);     
    }
}