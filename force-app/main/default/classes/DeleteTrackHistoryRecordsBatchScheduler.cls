global class DeleteTrackHistoryRecordsBatchScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    database.executebatch(new DeleteTrackHistoryRecordsBatch());
  }
}
