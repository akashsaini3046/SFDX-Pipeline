/*
 * Name: NewAccountTeamBatchScheduler
 * Purpose: Batch Scedulre for NewAccountTeamBatch.
 * Author: Nagarro
 * Created Date: 27-aug-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
global class NewAccountTeamBatchScheduler implements System.Schedulable {
  global void execute(System.SchedulableContext objSchedulableContext) {
    Account_Team_Notification__mdt objAccountTeamNotificationCustomMetadata = [
      SELECT Allow_Notification__c
      FROM Account_Team_Notification__mdt
      WHERE DeveloperName = 'AccountTeamNotification'
      LIMIT 1
    ];
    if (objAccountTeamNotificationCustomMetadata.Allow_Notification__c) {
      Database.executeBatch(new NewAccountTeamBatch(), 200);
    }
  }
}
