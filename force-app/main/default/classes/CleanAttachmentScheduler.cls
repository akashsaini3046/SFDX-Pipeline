public class CleanAttachmentScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new Clean1kbAttachmentBatch());
  }
}
