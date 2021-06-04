global class AccAndLocationUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
  global List<Address__c> addListFinal;

  global AccAndLocationUpdateBatch() {
    addListFinal = new List<Address__c>();
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          CVIF_Location_Id__c,
          LocationType__c,
          Account__r.CDM_Org_Id__c,
          Account__r.CVIF__c
        FROM Address__c
        WHERE
          Id IN (
            SELECT ParentId
            FROM Address__History
            WHERE Field = 'LocationType__c'
          )
          AND LastModifiedDate = LAST_N_DAYS:7
      ]
    );
  }

  global void execute(Database.BatchableContext bc, List<Address__c> addList) {
    for (Address__c addObj : addList) {
      addListFinal.add(addObj);
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
      ConstantClass.CVIF_ACC_ID;
    firstRow = firstRow + ConstantClass.COMMA_STRING + ConstantClass.CDM_ACC_ID;
    firstRow =
      firstRow +
      ConstantClass.COMMA_STRING +
      ConstantClass.CVIF_LOCATION_ID;
    firstRow =
      firstRow +
      ConstantClass.COMMA_STRING +
      ConstantClass.SITEUSERTYPECODE;
    firstRow = firstRow.replaceFirst(ConstantClass.COMMA_STRING, '');
    generatedCSVFile = firstRow + ConstantClass.NEXT_LINE;

    String fileRow = '';
    for (Address__c addObj : addListFinal) {
      fileRow = '';
      fileRow =
        fileRow +
        ConstantClass.COMMA_STRING +
        addObj.Account__r.CVIF__c;
      fileRow =
        fileRow +
        ConstantClass.COMMA_STRING +
        addObj.Account__r.CDM_Org_Id__c;
      fileRow =
        fileRow +
        ConstantClass.COMMA_STRING +
        addObj.CVIF_Location_Id__c;
      fileRow = fileRow + ConstantClass.COMMA_STRING + addObj.LocationType__c;
      fileRow = fileRow.replaceFirst(ConstantClass.COMMA_STRING, '');
      generatedCSVFile = generatedCSVFile + fileRow + ConstantClass.NEXT_LINE;
    }

    Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
    Blob csvBlob = blob.valueOf(generatedCSVFile);
    String csvName = Label.AccountAndBusinessLocationCSV;
    csvAttachment.setFileName(csvName);
    csvAttachment.setBody(csvBlob);
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    String subject = Label.AccountAndBusinessLocationSubject;
    email.setSubject(subject);
    email.setToAddresses(emailAddresses);
    email.setTargetobjectid(UserInfo.getUserId());
    email.setSaveAsActivity(false);
    email.setPlainTextBody(Label.AccountAndBusinessLocationBody);
    email.setFileAttachments(
      new List<Messaging.EmailFileAttachment>{ csvAttachment }
    );
    Messaging.SendEmailResult[] r = Messaging.sendEmail(
      new List<Messaging.SingleEmailMessage>{ email }
    );
  }
}
