/*
 * Name: MassOwnerChangeErrorEmail
 * Purpose: Clsss to send email to DL with error records
 * Author: Nagarro
 * Created Date: 29/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
public class MassOwnerChangeErrorEmail {
  public static void sendErrorEmai(
    DateTime objActionStartTime,
    Id IdActionPerformer
  ) {
    //Send error log to technical team
    List<Owner_Change_Logger__c> lstOwnerChangeLoger = new List<Owner_Change_Logger__c>();
    lstOwnerChangeLoger = [
      SELECT
        Id,
        Name,
        Detail_Description__c,
        Object_Type__c,
        Performed_By__r.Name,
        Record_Id__c,
        Time__c
      FROM Owner_Change_Logger__c
      WHERE
        Time__c = :objActionStartTime
        AND Performed_By__c = :IdActionPerformer
        AND Execution_Result__c = 'Failed'
      ORDER BY Name ASC
    ];
    if (lstOwnerChangeLoger != null && lstOwnerChangeLoger.size() > 0) {
      String strEmailBodyHeader = 'Hi,<br/><br/><br/>Please find below list of records which are failed during owner transfer:<br/><br/>';
      String strTable = '<table cellpadding="0" cellspacing="0" width="100%" align="center" border="1" style="border-collapse:collapse;"><tr><td>Sr. No.</td><td>Logger Id</td><td>Logger Number</td><td>Object Type</td><td>Performed By</td><td>Error Record Id</td><td>Time</td><td>Description</td></tr>';
      Integer intIndex = 1;
      for (Owner_Change_Logger__c objLog : lstOwnerChangeLoger) {
        strTable += '<tr>';
        strTable +=
          '<td>' +
          intIndex +
          '</td><td>' +
          objLog.Id +
          '</td><td>' +
          objLog.Name +
          '</td><td>' +
          objLog.Object_Type__c +
          '</td><td>' +
          objLog.Performed_By__r.Name +
          '</td><td>' +
          objLog.Record_Id__c +
          '</td><td>' +
          objLog.Time__c +
          '</td><td>' +
          objLog.Detail_Description__c +
          '</td><td>';
        strTable += '</tr>';
        intIndex++;
      }
      strTable += '</table><br/><br/>Please open the logger for more details.<br/><br/><br/>Thanks,<br/>Salesforce Notification System';

      List<Messaging.SingleEmailMessage> lstErrorSingleEmails = new List<Messaging.SingleEmailMessage>();
      Mass_Transfer_Error_DL__mdt objEmailDL = [
        SELECT Emails__c
        FROM Mass_Transfer_Error_DL__mdt
        LIMIT 1
      ];
      List<String> lstErroEmialId = new List<String>();
      for (String strEmail : objEmailDL.Emails__c.split(';;')) {
        lstErroEmialId.add(strEmail);
      }
      if (lstErroEmialId != null && lstErroEmialId.size() > 0) {
        Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
        objMail.setToAddresses(lstErroEmialId);
        objMail.setHTMLBody(strEmailBodyHeader + strTable);
        objMail.setSubject('Error during mass owner change');
        lstErrorSingleEmails.add(objMail);
      }
      if (!lstErrorSingleEmails.isEmpty()) {
        Messaging.sendEmail(lstErrorSingleEmails);
      }
    }
  }
}
