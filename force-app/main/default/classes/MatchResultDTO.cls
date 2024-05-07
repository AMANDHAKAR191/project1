public with sharing class MatchResultDTO {
    public Boolean matchStatus {get; set;}
    public List<String> notTrackedField {get; set;}
    public List<FieldHistoryDTO> fieldHistory {get; set;}
}