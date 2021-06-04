/**
 *
 * @author Nagarro/Himani
 * @version 1.0
 * @description
 *
 * PURPOSE
 *
 * This class handles all the inbound Emails sent to email id 'crowley.demo1@gmail.com' and creates lead record.
 * Attachments(if any) also get attached with the lead record.
 *
 * Date - 6th September 2018
 *
 **/

global class EmailToLeadHandler implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.inboundEmail email,
    Messaging.InboundEnvelope env
  ) {
    //Creates lead record with below information
    Lead leadObj = new Lead();
    leadObj.FirstName = email.fromname.substring(
      0,
      email.fromname.indexOf(' ')
    );
    leadObj.LastName = email.fromname.substring(email.fromname.indexOf(' '));
    leadObj.Email = email.fromAddress;
    leadObj.Company = ConstantClass.COMPANY;
    leadObj.LeadSource = ConstantClass.LEADSOURCE;

    leadObj.Description =
      'Subject: ' +
      email.subject +
      '\nDescription: ' +
      email.plainTextBody;
    leadObj.CreatedviaEMail__c = true;

    //Running assignment rule
    AssignmentRule AR = new AssignmentRule();
    AR = [
      SELECT id
      FROM AssignmentRule
      WHERE SobjectType = 'Lead' AND Active = TRUE
      LIMIT 1
    ];
    Database.DMLOptions dmlOpts = new Database.DMLOptions();
    dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
    leadObj.setOptions(dmlOpts);

    insert leadObj;

    //Attaching attachments to the record
    List<Attachment> attachmentList = new List<Attachment>();
    if (email.binaryAttachments != null) {
      for (integer i = 0; i < email.binaryAttachments.size(); i++) {
        Attachment attachmentObj = new Attachment();
        attachmentObj.ParentId = leadObj.Id;
        attachmentObj.Name = email.binaryAttachments[i].filename;
        attachmentObj.Body = email.binaryAttachments[i].body;
        attachmentList.add(attachmentObj);
      }
    }
    if (!attachmentList.isEmpty()) {
      insert attachmentList;
    }

    return null;
  }
}
