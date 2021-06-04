global class AccAndLocationUpdateBatchSchedular implements Schedulable {
  global void execute(SchedulableContext sc) {
    AccAndLocationUpdateBatch b = new AccAndLocationUpdateBatch();
    database.executebatch(b);
  }
}
