/*
 * Name: AccountTeamMemberInfoDeleteBatchSchedule
 * Purpose: Schedule Batch Class AccountTeamMemberInfoDeleteBatch to run daily.
 * Author: Nagarro
 * Created Date: 14-Jan-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class AccountTeamMemberInfoDeleteBatchSchedule implements Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new AccountTeamMemberInfoDeleteBatch());
  }
}
