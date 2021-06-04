/**
 *
 * @author Nagarro/Himani
 * @version 1.0
 * @description
 *
 * PURPOSE
 *
 * Test class for EmailToLeadHandler
 *
 * Date - 6th September 2018
 *
 **/

@isTest
public class EmailToLeadHandler_Test {
  static testMethod void EmailToLeadHandler_TestMethod() {
    Lead leadObj = new Lead();
    leadObj.FirstName = 'FirstName';
    leadObj.LastName = 'LastName';
    leadObj.Email = 'email@test.com';
    leadObj.Company = 'Crowley';
    leadObj.LeadSource = ConstantClass.LEADSOURCE;
    insert leadObj;

    System.assertNotEquals(null, leadObj);

    test.startTest();
    Messaging.InboundEmail email1 = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
    Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
    email1.subject = 'This is the email subject';
    email1.plainTextBody = 'This a test email body. For testing purpose only.';
    email1.fromAddress = 'from@test.com';
    email1.fromName = 'Test Email';

    //Set body of the attachment
    inAtt.body = blob.valueOf('test');
    inAtt.fileName = 'my attachment name';
    inAtt.mimeTypeSubType = 'plain/txt';
    inAtt.headers = email1.headers;
    email1.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{
      inAtt
    };

    //Call the class and test it with data in the testMethod
    EmailToLeadHandler emailServiceObj1 = new EmailToLeadHandler();
    emailServiceObj1.handleInboundEmail(email1, env1);
    test.stopTest();
  }
}
