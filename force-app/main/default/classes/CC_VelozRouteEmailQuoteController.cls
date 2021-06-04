/*
 * 08-10-2020 – Drupad Preenja – Created this class for handling functionality related to Email for Quote Summary on the Veloz Community.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 05-09-2020
 * @author      : Nagarro
 * @description : Used as Controller class for CC_VelozRouteEmailQuote Aura Component
 * @history     : Version 1.0
 * @test class  : CC_VelozRouteEmailQuoteControllerTest
 */
public without sharing class CC_VelozRouteEmailQuoteController {
  /*
   * @purpose     : Method to send email to the email address provided with the attached summary of the quote Id provided
   * @parameter   : emailAddress - Email Addresses (; seperated)
   * @parameter   : contactName - Contact Name provided on the UI
   * @parameter   : contactNumber - Contact Number provided on the UI
   * @parameter   : companyName - Company Name provided on the UI
   * @parameter   : agree - Agree or Disagree checkbox value
   * @parameter   : quoteId - Quote Id
   * @return      : void
   */
  @AuraEnabled
  public static void sendEmail(
    String emailAddress,
    String contactName,
    String contactNumber,
    String companyName,
    Boolean agree,
    Id quoteId,
    Boolean iComm
  ) {
    sendEmailToQuotes(emailAddress, new Set<Id>{ quoteId }, iComm);
  }

  /*
   * @purpose     : Method to send email to the email address provided with the attached summary of the Set of quote Ids provided
   * @parameter   : emailAddress - Email Addresses (; seperated)
   * @parameter   : Set of Ids - Set of Quote Ids
   * @return      : void
   */
  public static void sendEmailToQuotes(
    String emailAddresses,
    Set<Id> quoteIds,
    Boolean iComm
  ) {
    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    String noReplyCustomLabel = System.Label.From_Email_Address_for_Quote_Summary;
    String emailTemplateName = System.Label.Quote_Summary_Email_Template_Name;
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
    List<String> subjectQuoteNamesList = new List<String>();
    List<Quote__c> quotes = CC_WithoutSharingUtility.getQuoteWithChargeLineByQuoteIds(
      quoteIds
    );
    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
    System.debug(UserInfo.getUserId());
    System.debug(quotes);
    for (Quote__c quote : quotes) {
      subjectQuoteNamesList.add(quote.Name);
      Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
      PageReference pref;
      if (iComm == true) {
        pref = page.CC_EmployeeQuoteRecordPDF;
      } else {
        pref = page.QuoteRecordPDF;
      }
      pref.getParameters().put('Id', quote.Id);
      Blob b;
      if (Test.isRunningTest()) {
        b = blob.valueOf('Unit.Test');
      } else {
        b = pref.getContentAsPDF();
      }
      System.debug(quote.Name);
      attach.setFileName(quote.Name + '.pdf');
      attach.setBody(b);
      attachments.add(attach);
    }
    subject = subject.replace(
      '{!Quote__c.Name}',
      String.join(subjectQuoteNamesList, ', ')
    );
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
    System.debug(emailAddressArray);
    String[] sendTo = emailAddressArray;
    semail.setToAddresses(sendTo);
    semail.setFileAttachments(attachments);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ semail });
  }
}
