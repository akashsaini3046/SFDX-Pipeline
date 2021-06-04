/*
 * Name: AccountTeamMemberInfoDeleteBatch
 * Purpose: Batch Class to delete 3 month old records in Account Team Member Info object.
 * Author: Nagarro
 * Created Date: 13-Jan-2020
 * Modification History
 *  Modification # #  Story/Defect#      Modified By     Date   Description
 */
public class AccountTeamMemberInfoDeleteBatch implements Database.Batchable<sObject>, Database.stateful {
  public Integer countOfRecords = 0;

  public Database.QueryLocator start(
    Database.BatchableContext objBatchableContext
  ) {
    Integer days = Integer.valueOf(
      System.Label.Last_n_days_for_Account_Team_Member_Info_Delete_Batch
    );
    Date tilldate = System.today() - days;
    if (Test.isRunningTest()) {
      return Database.getQueryLocator(
        [SELECT Id FROM Account_Team_Member_Info__c]
      );
    } else {
      return Database.getQueryLocator(
        [
          SELECT Id
          FROM Account_Team_Member_Info__c
          WHERE LastModifiedDate <= :tilldate
        ]
      );
    }
  }

  public void Execute(
    Database.BatchableContext objBatchableContext,
    List<Account_Team_Member_Info__c> accountTeamMemberInfoList
  ) {
    if (accountTeamMemberInfoList.size() > 0) {
      countOfRecords = countOfRecords + accountTeamMemberInfoList.size();
      delete accountTeamMemberInfoList;
    }
  }

  public void finish(Database.BatchableContext objBatchableContext) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> sendTo = new List<String>();
    String emailIds = System.Label.Email_Id_to_be_notified_for_Account_Team_Member_Info_Batch_deletion;
    sendTo = emailIds.split(',');
    System.debug('sendTo: ' + sendTo);
    mail.setToAddresses(sendTo);
    mail.setSubject('Account Team Member Info Delete Batch');
    String body = 'Number of records deleted ' + countOfRecords;
    mail.setHtmlBody(body);
    mails.add(mail);
    Messaging.sendEmail(mails);
  }
}
