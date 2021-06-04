global class AccOwnerAndMakSegUpdateBatchSchedular implements Schedulable {
  global void execute(SchedulableContext sc) {
    AccountOwnerAndMktSegmentUpdateBatch b = new AccountOwnerAndMktSegmentUpdateBatch();
    database.executebatch(b);
  }
}
