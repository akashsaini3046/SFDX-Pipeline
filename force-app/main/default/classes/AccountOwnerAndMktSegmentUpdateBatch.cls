global class AccountOwnerAndMktSegmentUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
  global List<Account> accountListFinal;

  global AccountOwnerAndMktSegmentUpdateBatch() {
    accountListFinal = new List<Account>();
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          Name,
          CVIF__c,
          CDM_Org_Id__c,
          Owner.Name,
          Owner.FederationIdentifier,
          Industry,
          Parent_CVIF_Id__c
        FROM Account
        WHERE
          Id IN (
            SELECT AccountId
            FROM AccountHistory
            WHERE Field IN ('Industry', 'Owner')
          )
          AND CVIF__c != ''
          AND LastModifiedDate = LAST_N_DAYS:7
      ]
    );
  }

  global void execute(Database.BatchableContext bc, List<Account> accountList) {
    for (Account accObj : accountList) {
      accountListFinal.add(accObj);
    }
  }

  global void finish(Database.BatchableContext bc) {
    List<String> emailAddresses = new List<String>();

    emailAddresses.addAll(CDM_Team_Email_Addresses__c.getAll().keySet());

    String generatedCSVFile = '';
    String firstRow = '';
    firstRow =
      firstRow +
      ConstantClass.COMMA_STRING +
      ConstantClass.SALESFORCE_ID;
    firstRow =
      firstRow +
      ConstantClass.COMMA_STRING +
      ConstantClass.ACCOUNT_NAME_STRING;
    firstRow = firstRow + ConstantClass.COMMA_STRING + ConstantClass.CVIF_ID;
    firstRow = firstRow + ConstantClass.COMMA_STRING + ConstantClass.CDM_ID;
    firstRow = firstRow + ConstantClass.COMMA_STRING + ConstantClass.OWNER_NAME;
    firstRow =
      firstRow +
      ConstantClass.COMMA_STRING +
      ConstantClass.OWNER_FEDERATION_ID;
    firstRow =
      firstRow +
      ConstantClass.COMMA_STRING +
      ConstantClass.MARKET_SEGMENT;
    firstRow =
      firstRow +
      ConstantClass.COMMA_STRING +
      ConstantClass.PARENT_CVIF_ID;
    firstRow = firstRow.replaceFirst(ConstantClass.COMMA_STRING, '');
    generatedCSVFile = firstRow + ConstantClass.NEXT_LINE;

    String fileRow = '';
    for (Account accObj : accountListFinal) {
      fileRow = '';
      fileRow = fileRow + ConstantClass.COMMA_STRING + accObj.Id;
      fileRow = fileRow + ConstantClass.COMMA_STRING + '"' + accObj.Name + '"';
      fileRow = fileRow + ConstantClass.COMMA_STRING + accObj.CVIF__c;
      fileRow = fileRow + ConstantClass.COMMA_STRING + accObj.CDM_Org_Id__c;
      fileRow = fileRow + ConstantClass.COMMA_STRING + accObj.Owner.Name;
      fileRow =
        fileRow +
        ConstantClass.COMMA_STRING +
        accObj.Owner.FederationIdentifier;
      fileRow = fileRow + ConstantClass.COMMA_STRING + accObj.Industry;
      fileRow = fileRow + ConstantClass.COMMA_STRING + accObj.Parent_CVIF_Id__c;
      fileRow = fileRow.replaceFirst(ConstantClass.COMMA_STRING, '');
      generatedCSVFile = generatedCSVFile + fileRow + ConstantClass.NEXT_LINE;
    }

    Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
    Blob csvBlob = blob.valueOf(generatedCSVFile);
    String csvName = Label.AccountOwnerAndMKTSegmentCSV;
    csvAttachment.setFileName(csvName);
    csvAttachment.setBody(csvBlob);
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    String subject = Label.AccountOwnerAndMKTSegmentSubject;
    email.setSubject(subject);
    email.setToAddresses(emailAddresses);
    email.setTargetobjectid(UserInfo.getUserId());
    email.setSaveAsActivity(false);
    email.setPlainTextBody(Label.AccountOwnerAndMKTSegmentBody);
    email.setFileAttachments(
      new List<Messaging.EmailFileAttachment>{ csvAttachment }
    );
    Messaging.SendEmailResult[] r = Messaging.sendEmail(
      new List<Messaging.SingleEmailMessage>{ email }
    );
  }
}
