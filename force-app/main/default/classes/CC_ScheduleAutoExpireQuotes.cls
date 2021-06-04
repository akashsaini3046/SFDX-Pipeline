global class CC_ScheduleAutoExpireQuotes implements Schedulable {
  global void execute(SchedulableContext sc) {
    CC_AutoExpireQuotes aeq = new CC_AutoExpireQuotes();
    Id batchId = Database.executeBatch(aeq);
    AsyncApexJob job = [
      SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
      FROM AsyncApexJob
      WHERE Id = :batchId
    ];
    System.debug(job);
  }
}
