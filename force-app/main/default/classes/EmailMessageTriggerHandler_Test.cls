/*
 * Name: EmailMessageTriggerHandler_Test
 * Purpose: Test class for EmailMessageTriggerHandler class.
 * Author: Nagarro
 * Created Date: 6-Mar-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest
public class EmailMessageTriggerHandler_Test {
  private Opportunity opp;
  @testSetup
  static void dataSetup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;
    TriggerHandler.bypass('AccountTriggerHandler');
    List<Account> accObj = TestDataUtility.createAccount(
      'Account 123',
      null,
      null,
      null,
      false,
      1
    );
    insert accObj;
    TriggerHandler.clearbypass('AccountTriggerHandler');
    TriggerHandler.bypass('AddressTriggerHandler');
    List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
      accObj,
      'BL1',
      'City1',
      'CA',
      '1111111',
      '88888888888',
      'US',
      1
    );
    insert businessLocationObj;
    TriggerHandler.clearbypass('AddressTriggerHandler');
    TriggerHandler.bypass('ContactTriggerHandler');
    List<Contact> conList = TestDataUtility.createContact(
      null,
      accObj,
      businessLocationObj,
      'Test',
      ' con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert conList;
    TriggerHandler.clearbypass('ContactTriggerHandler');
    System.debug('****' + conList);
    String conObj;
    for (Contact con : conList) {
      conObj = con.Email;
      system.debug('****' + con);
    }
    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );
    update standardPricebook;
    TriggerHandler.bypass('OpportunityTriggerHandler');
    List<Opportunity> opp = TestDataUtility.createOpportunity(
      null,
      null,
      'Opp1',
      conList,
      accObj,
      ConstantClass.PROPOSAL_PRICE_QUOTE_OPP_STAGE,
      null,
      System.today(),
      System.today(),
      'CrowleyFresh',
      null,
      false,
      1
    );
    insert opp;
    TriggerHandler.clearbypass('OpportunityTriggerHandler');
    Id oppObj;
    for (Opportunity opp1 : opp) {
      oppObj = opp1.Id;
    }
    EmailMessage outGoingMail = TestDataUtility.createEmailMessage(
      'test@test.com',
      conObj,
      'This is the message subject.',
      'This is the message body. Send Quote ' + oppObj,
      oppObj
    );
    insert outGoingMail;

    List<Case> cases = TestDataUtility.createBLRevisionCase(
      accObj,
      conList,
      null,
      'Subject',
      null,
      'Web',
      Userinfo.getUserId(),
      'Open',
      1
    );
    insert cases;
    Id csId;
    Case cs = new Case();
    List<RecordType> rts = [
      SELECT Id, Name
      FROM RecordType
      WHERE Name = 'BL Revision'
      LIMIT 1
    ];
    for (Case cs1 : cases) {
      csId = cs1.Id;
    }
    if (!rts.isEmpty()) {
      cs.Id = csId;
      cs.RecordTypeId = rts[0].Id;
      cs.Case_Auto_Close__c = true;
      cs.Status = 'Resolving Case';
      cs.Resolution__c = 'No correction needed';
      cs.BL_Resolution_Category__c = 'Parties';
      cs.Resolution_Sub_category__c = 'Prepaid / Collect';
      cs.Department_Responsible_for_Error__c = 'Pricing';
      cs.Final_Resolution_Comments__c = 'Test Comments';
    }
    update cs;
    EmailMessage outGoingMail1 = TestDataUtility.createEmailMessage(
      'test@test.com',
      'test@test.com',
      'This is the message subject.',
      'This is the message body. Send Quote ' + cs.Id,
      cs.id
    );
    insert outGoingMail1;

    List<Case> BookingRequestCase = TestDataUtility.createBookingRequestCase(
      accObj,
      conList,
      null,
      'Booking Request Case 1',
      'Description 1',
      'EDI/GT NEXUS',
      UserInfo.getUserId(),
      'Open',
      1
    );
    insert BookingRequestCase;

    list<case> customerInquirycase = TestDataUtility.createBLRevisionCase(
      accObj,
      conList,
      null,
      'Customer Inquiry Subject',
      null,
      'Email',
      Userinfo.getUserId(),
      'Open',
      1
    );
    insert customerInquirycase;
    List<RecordType> crts = [
      SELECT Id, Name
      FROM RecordType
      WHERE Name = 'Customer Inquiry'
      LIMIT 1
    ];
    for (Case cs1 : customerInquirycase) {
      csId = cs1.Id;
    }
    cs = new Case();
    if (!crts.isEmpty()) {
      cs.Id = csId;
      cs.RecordTypeId = crts[0].Id;
      cs.Case_Auto_Close__c = true;
      cs.Status = 'Closed Resolved';
      cs.Request_Type__c = 'SIQ'; //Service Inquiry
      cs.Customer_Inquiry_Resolution__c = 'Service provided by Crowley';
    }
    update cs;

    Case newCase = [
      SELECT Id
      FROM Case
      WHERE RecordType.Id = :System.Label.Booking_Request_Record_Type
      LIMIT 1
    ];
    newCase.Status = 'Closed Resolved';
    update newCase;
    system.debug('newcase' + newCase);

    Test.startTest();
    Set<EmailMessage> InComingMailset = new Set<EmailMessage>();
    List<EmailMessage> InComingMailLi = new List<EmailMessage>();
    InComingMailLi.add(
      new EmailMessage(
        fromaddress = 'test@test.com',
        toAddress = System.Label.Crowley_Arrival_Notice_Email,
        subject = 'This is the message subject.',
        TextBody = 'This is the message body. Send Quote ' + cs.Id,
        HtmlBody = 'This is the message HTML body.',
        RelatedToId = cs.id,
        incoming = true
      )
    );
    InComingMailLi.add(
      new EmailMessage(
        fromaddress = 'test@test.com',
        toAddress = System.Label.Crowley_Arrival_Notice_Email +
          ', ' +
          System.label.Crowley_BL_Revision_Email,
        subject = 'This is the message subject.',
        TextBody = 'This is the message body. Send Quote ' + cs.Id,
        HtmlBody = 'This is the message HTML body.',
        RelatedToId = cs.id,
        incoming = true
      )
    );
    InComingMailLi.add(
      new EmailMessage(
        fromaddress = 'test@test.com',
        toAddress = 'test@test.com',
        subject = 'This is the message subject Trouble Lane.',
        TextBody = 'This is the message body. Send Quote ' + cs.Id,
        HtmlBody = 'This is the message HTML body.',
        RelatedToId = cases[0].id,
        incoming = true
      )
    );
    InComingMailLi.add(
      new EmailMessage(
        fromaddress = 'test@test.com',
        toAddress = system.label.Crowley_Booking_Request_Email +
          ', ' +
          system.label.Crowley_Customer_Inquiry_Email,
        subject = 'trouble lane This is the message subject test',
        TextBody = 'This is the message body. Send Quote ' + cs.Id,
        HtmlBody = 'This is the message HTML body.',
        RelatedToId = cs.id,
        incoming = true
      )
    );
    InComingMailLi.add(
      new EmailMessage(
        fromaddress = 'test@test.com',
        toAddress = system.label.Crowley_Booking_Request_Email,
        subject = 'Booking Request trouble lane This is the message subject test',
        TextBody = 'This is the message body. Send Quote ' + newCase.Id,
        HtmlBody = 'This is the message HTML body.',
        RelatedToId = newCase.id,
        incoming = true
      )
    );
    // InComingMailset.add(new EmailMessage(fromaddress = 'test@test.com', toAddress = 'test@test.com', subject = 'This is the message subject.', TextBody = 'This is the message body. Send Quote '+cs.Id, RelatedToId=cs.id,incoming=true));
    /*InComingMailLi.add(TestDataUtility.createIncomingEmailMessage('test@test.com', System.Label.Crowley_Arrival_Notice_Email, 'This is the message subject.', 'This is the message body. Send Quote '+cs.Id, cs.id));
        InComingMailLi.add(TestDataUtility.createIncomingEmailMessage('test@test.com', 'test@test.com', 'This is the message subject Trouble Lane.', 'This is the message body. Send Quote '+cs.Id, cs.id));
        InComingMailLi.add(TestDataUtility.createIncomingEmailMessage('test@test.com', 'test@test.com', 'This is the message subject', 'This is the message body. Send Quote '+cs.Id, cs.id));*/
    //InComingMailLi.addAll(InComingMailset);
    insert InComingMailLi;
    Test.stopTest();
  }
  static testMethod void emailMessageTriggerHandler_TestMethod() {
    //Opportunity opp=[Select Id,StageName from Opportunity where Name='Opp1'];
    //System.assertEquals(opp.StageName, ConstantClass.PROPOSAL_PRICE_QUOTE_OPP_STAGE);
    //EmailMessage outGoingMail=[Select Id,RelatedToId,TextBody from EmailMessage where RelatedToId=:opp.Id limit 10];
    Test.startTest();
    // System.assertEquals(opp.Id, outGoingMail.RelatedToId);
    //System.assertEquals(outGoingMail.TextBody.contains('Send Quote '+opp.Id), true);
    Test.stopTest();
  }

  static testMethod void resolvingCaseOnEmail() {
    // Case cases=[Select Id from Case where Origin='Web' limit 1];
    // EmailMessage outGoingMail=[Select Id,RelatedToId,TextBody from EmailMessage where RelatedToId=:cases.Id limit 10];
    Test.startTest();
    // System.assertEquals(cases.Id, outGoingMail.RelatedToId);
    // System.assertEquals(outGoingMail.TextBody.contains('Send Quote '+cases.Id), true);
    Test.stopTest();
  }
}
