global class NeglectedAccountReportScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    NeglectedAccountBatch nBatch = new NeglectedAccountBatch();
    Database.executeBatch(nBatch);
  }
}
