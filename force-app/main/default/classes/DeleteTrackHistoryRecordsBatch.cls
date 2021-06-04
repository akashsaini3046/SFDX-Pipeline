global class DeleteTrackHistoryRecordsBatch implements Database.batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query =
      'SELECT Id FROM Track_History__c WHERE CreatedDate = LAST_N_DAYS:' +
      System.Label.TrackHistoryRecordsToBeDeleted;
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    delete scope;
  }

  global void finish(Database.BatchableContext BC) {
  }
}
