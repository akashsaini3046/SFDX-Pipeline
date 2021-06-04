public without sharing class CC_BOLEmailSendController {
  @AuraEnabled
  public static void sendEmail(
    String emailAddress,
    String bookingId,
    Id bolId,
    String bolName,
    String strType,
    String strEmailTemplate
  ) {
    shippingInstructionSendEmail(
      emailAddress,
      bookingId,
      bolId,
      bolName,
      strType,
      strEmailTemplate
    );
  }

  public static void shippingInstructionSendEmail(
    String emailAddresses,
    String bookingId,
    Id bolId,
    String bolName,
    String strType,
    String strEmailTemplate
  ) {
    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    String noReplyCustomLabel = System.Label.From_Email_Address_for_Shipping_Instruction;
    String emailTemplateName = strEmailTemplate;
    OrgWideEmailAddress crowleyNoReply = [
      SELECT Id, Address
      FROM OrgWideEmailAddress
      WHERE Displayname = :noReplyCustomLabel
    ];
    EmailTemplate template = [
      SELECT id, Subject, HtmlValue, Body
      FROM EmailTemplate
      WHERE name = :emailTemplateName
    ];
    String subject = template.Subject;
    String htmlBody = template.HtmlValue;
    String plainBody = template.Body;
    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    PageReference pref;
    if (strType == 'Shipping Instruction') {
      pref = page.CC_ViewShippingInstructionPDF;
    } else if (strType == 'Bill of Lading') {
      pref = page.CC_ReadyForReleaseViewPDF;
    }

    pref.getParameters().put('bookingId', bookingId);
    pref.getParameters().put('bolId', bolId);
    Blob b;
    if (Test.isRunningTest()) {
      b = blob.valueOf('Unit.Test');
    } else {
      b = pref.getContentAsPDF();
    }
    attach.setFileName(strType + ' - ' + bolName + '.pdf');
    attach.setBody(b);
    attachments.add(attach);
    subject = subject.replace('{!Bill_Of_Lading__c.Name}', bolName);
    //semail.setSenderDisplayName('Crowley');
    semail.setSubject(subject);
    semail.setHtmlBody(htmlBody);
    semail.setPlainTextBody(plainBody);
    semail.setUseSignature(false);
    semail.setOrgWideEmailAddressId(crowleyNoReply.id);
    semail.setTreatTargetObjectAsRecipient(false);
    semail.setTargetObjectId(UserInfo.getUserId());
    List<String> emailsAddrs = emailAddresses.split(';');
    String[] emailAddressArray = new List<String>(emailsAddrs.size());
    for (Integer i = 0; i < emailsAddrs.size(); i++) {
      emailAddressArray[i] = emailsAddrs.get(i);
    }
    String[] sendTo = emailAddressArray;
    semail.setToAddresses(sendTo);
    semail.setFileAttachments(attachments);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ semail });
  }
}
